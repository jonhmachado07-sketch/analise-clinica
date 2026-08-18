# 06 — O lastro: modelo de dados dos eventos

> **O que este documento resolve.** Os documentos 01–05 desenham *o processo*. Este desenha *a memória do processo* — a trilha completa e auditável de cada pessoa, do primeiro clique no anúncio até a enésima recompra, incluindo tudo que aconteceu no meio e tudo que **deveria ter acontecido e não aconteceu**.
>
> **Premissa de arquitetura.** Kommo e Meta deixam de ser onde os dados moram e passam a ser **fontes de entrada**. O banco é a fonte de verdade. Nenhuma análise volta a depender de export manual.
>
> ⚠️ **Assunção:** o destino é **PostgreSQL**. O modelo roda em Supabase, Neon ou Postgres gerenciado sem alteração. Ver §9 para o que muda em BigQuery ou em planilha.

---

## 1. O princípio: evento é fato, estado é projeção

A razão de o projeto inteiro estar cego hoje é que os sistemas guardam **estado** e jogam fora o **fato**. O Kommo sabe que um contato existe; não sabe que ele foi respondido às 14h32 do dia 3, que a segunda tentativa foi no dia 5 e que ele parou de responder depois da mensagem de preço.

```
   FATO (imutável, append-only)          ESTADO (mutável, derivado)
   ────────────────────────────          ──────────────────────────
   agenda.agendamento.criado             agendamento.status = 'agendado'
   agenda.agendamento.confirmado    ──▶  agendamento.status = 'confirmado'
   agenda.agendamento.no_show            agendamento.status = 'no_show'
```

**Três regras que não se quebram:**

1. **Nada é apagado nem editado na tabela `evento`.** Correção é um evento novo de compensação.
2. **Todo estado precisa ser reconstruível** rodando os eventos em ordem. Se não for, o estado está guardando informação que o lastro perdeu.
3. **Todo evento aponta para uma pessoa.** Evento órfão vai para quarentena, não para o lastro.

---

## 2. As três camadas, 14 tabelas

```
┌─── ENTRADA ───────┐   ┌─── LASTRO ────────┐   ┌─── ESTADO ─────────────────┐
│                   │   │                   │   │                            │
│  Kommo    ──┐     │   │  tipo_evento      │   │  pessoa    identidade      │
│  Meta     ──┼──▶  │   │  evento  ◀────────┼───│  oportunidade agendamento  │
│  Agenda   ──┘     │   │  (append-only)    │   │  venda   venda_item        │
│                   │   │                   │   │  protocolo  expectativa    │
│  staging_bruto    │   │  ▲                │   │  tag  pessoa_tag           │
│  (payload cru)    │   │  │ projeta        │   │  procedimento  campanha    │
└───────────────────┘   └──┼────────────────┘   └────────────────────────────┘
                           │                                  │
                           └──────────────┐                   ▼
                                          │        ┌─── DERIVADO ────┐
                                          └────────│  segmento_dia   │
                                                   │  (snapshot)     │
                                                   └─────────────────┘
```

| Camada | Tabelas | Papel |
|---|---|---|
| **Entrada** | `staging_bruto` | Payload cru de cada fonte, sem transformação. É o seguro contra erro de parsing. |
| **Lastro** | `tipo_evento`, `evento` | A trilha. Imutável. |
| **Estado** | `pessoa`, `identidade`, `oportunidade`, `agendamento`, `venda`, `venda_item`, `protocolo`, `expectativa`, `tag`, `pessoa_tag`, `procedimento`, `campanha` | Projeções consultáveis. |
| **Derivado** | `segmento_dia` | O motor de segmentação materializado, com histórico. |

---

## 3. O núcleo do lastro

```sql
-- ─────────────────────────────────────────────────────────────
-- PESSOA: uma linha por ser humano. Nunca duplica.
-- ─────────────────────────────────────────────────────────────
create table pessoa (
  pessoa_id     bigserial primary key,
  nome          text,
  nascimento    date,
  sexo          text,
  cidade        text,
  bairro        text,
  consentimento boolean not null default false,   -- LGPD: hoje 99,9% = 'Não'
  consentido_em timestamptz,
  criado_em     timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────
-- IDENTIDADE: as N chaves que apontam para a mesma pessoa.
-- É o que resolve o problema de identity stitching entre fontes.
-- ─────────────────────────────────────────────────────────────
create table identidade (
  identidade_id bigserial primary key,
  pessoa_id     bigint not null references pessoa,
  tipo          text   not null,   -- telefone8 | cpf | ctwa_clid | kommo_id | agenda_id | email
  valor         text   not null,
  confianca     text   not null,   -- maxima | alta | media
  fonte         text   not null,   -- kommo | meta | agenda | cadastro
  visto_em      timestamptz not null default now(),
  unique (tipo, valor)
);
create index on identidade (pessoa_id);
```

**Hierarquia de resolução** — herdada de `mapa_de_dados/04` §1, testada em 10 de 10 casos sem falso positivo:

| Ordem | Chave | Confiança | Cobertura hoje |
|---|---|---|---|
| 1 | `cpf` (só dígitos) | máxima | 7,6% no CRM · quase total no cadastro |
| 2 | `telefone8` (8 últimos dígitos) | alta | 85,6% no CRM · 100% em vendas |
| 3 | `ctwa_clid` | máxima *(quando existir)* | 0% |
| 4 | nome completo 2+ palavras | média — último recurso | 97,1%, mas sujo |

⚠️ **Nome de uma palavra nunca é chave.** A base tem dezenas de "Gabriela", "Débora", "Carol" — e também `.`, `...`, "Binha", "Duda". A junção por nome teria falhado em 2 dos 3 casos completos do teste (`Vidal Ludimylla` ≠ `Ludimylla dos Santos Vidal`).

```sql
-- ─────────────────────────────────────────────────────────────
-- TIPO_EVENTO: o catálogo. Nenhum evento entra sem estar aqui.
-- ─────────────────────────────────────────────────────────────
create table tipo_evento (
  codigo      text primary key,        -- 'lead.contato.respondido'
  dominio     text not null,           -- midia|lead|agenda|venda|entrega|relacao
  descricao   text not null,
  ciclico     boolean not null default false,  -- gera expectativa de repetição?
  ativo       boolean not null default true
);

-- ─────────────────────────────────────────────────────────────
-- EVENTO: o lastro. Append-only. Nunca update, nunca delete.
-- ─────────────────────────────────────────────────────────────
create table evento (
  evento_id      bigserial primary key,
  pessoa_id      bigint      not null references pessoa,
  tipo           text        not null references tipo_evento(codigo),
  ocorrido_em    timestamptz not null,          -- quando aconteceu no mundo
  registrado_em  timestamptz not null default now(),  -- quando chegou aqui
  fonte          text        not null,          -- kommo | meta | agenda | manual | sistema
  ator           text,                          -- QUEM fez: atendente, profissional, 'automacao'
  canal          text,                          -- whatsapp | presencial | telefone | email
  ref_tipo       text,                          -- oportunidade|agendamento|venda|protocolo
  ref_id         bigint,                        -- id do objeto relacionado
  valor          numeric(12,2),                 -- quando o evento move dinheiro
  dados          jsonb not null default '{}',   -- payload específico do tipo
  chave_idem     text unique                    -- idempotência da ingestão
);
create index on evento (pessoa_id, ocorrido_em);
create index on evento (tipo, ocorrido_em);
create index on evento using gin (dados);
```

**`ocorrido_em` ≠ `registrado_em`** é o que permite reprocessar histórico sem inventar cronologia — e é como os dados até 25/12/2025 entram junto com os novos sem se misturarem.

**`chave_idem`** é o que torna a ingestão segura para repetir. Formato: `{fonte}:{id_na_fonte}:{tipo}`. Rodar o mesmo import duas vezes não duplica nada.

**`ator`** é o campo que hoje não existe em nenhuma das três fontes — `Responsável` é constante em 100% das 1.423 vendas, o CRM é quase monocolor, e no WhatsApp Mayara, Vanessa, Bandeira, Lorrainy e Kátia atendem sob a mesma identidade. Sem ele, nenhuma análise de desempenho por pessoa é possível.

---

## 4. O catálogo de eventos — 34 tipos, 6 domínios

Convenção de nome: **`dominio.objeto.acao`**, sempre no particípio. Legível numa timeline sem tradução.

### `midia` — antes de existir lead
| Código | Quando | Campos em `dados` |
|---|---|---|
| `midia.anuncio.clicado` | clique no CTA do anúncio | `campaign_id`, `adset_id`, `ad_id` |
| `midia.conversa.iniciada` | clique no botão do WhatsApp | **`ctwa_clid`**, `produto_anunciado` |

⚠️ **Estes dois eventos são a resposta ao vazamento de 51%.** Hoje 6.620 conversas iniciadas no Meta produzem 3.385 contatos no CRM e ninguém sabe onde os outros 3.235 foram parar. Com `midia.conversa.iniciada` no lastro, a diferença entre ele e `lead.criado` deixa de ser mistério e vira uma consulta.

### `lead` — do primeiro contato à avaliação agendada
| Código | Ciclíco | `dados` |
|---|---|---|
| `lead.criado` | — | `origem`, `campanha`, `produto_interesse` |
| `lead.contato.tentado` | ✓ | `tentativa_n`, `canal` |
| `lead.contato.respondido` | — | `latencia_seg` |
| `lead.qualificado` | — | `motivacao`, `ja_fez_procedimento`, `regiao`, `contraindicacao` |
| `lead.etapa.movido` | ✓ | `de`, `para`, `dias_na_etapa` |
| `lead.perdido` | — | `motivo` (lista fechada de 8) |
| `lead.reaberto` | ✓ | `motivo` |

### `agenda` — o domínio hoje 100% cego
| Código | `dados` |
|---|---|
| `agenda.agendamento.criado` | `antecedencia_h`, `procedimento`, `profissional` |
| `agenda.agendamento.confirmado` | `tentativa` (D-1, D-0) |
| `agenda.agendamento.remarcado` | `agendamento_origem_id`, `motivo` |
| `agenda.agendamento.cancelado` | `por` (cliente\|clinica), `motivo` |
| **`agenda.no_show`** | `avisou` (bool) |
| **`agenda.compareceu`** | `atraso_min` |

**`agenda.compareceu` é o evento mais importante do catálogo inteiro.** Sem ele, "não vendeu" e "não apareceu" são a mesma linha em branco — e a conversão avaliação → pago de 30,4% continua sendo um piso, não uma medida.

### `venda`
| Código | `dados` |
|---|---|
| `venda.proposta.apresentada` | `valor_tabela`, `valor_proposto`, `protocolo`, `total_sessoes` |
| `venda.fechada` | `forma_pagamento`, `parcelas`, `desconto_pct` |
| `venda.perdida` | `motivo` (lista fechada de 6) |
| `venda.item.adicionado` | `procedimento_id`, `qtd` |
| `venda.nf.emitida` | `numero`, `competencia` |

### `entrega` — os dados que não existem em fonte nenhuma
| Código | Cíclico | `dados` |
|---|---|---|
| `entrega.protocolo.iniciado` | — | `total_sessoes` |
| `entrega.sessao.realizada` | ✓ | `sessao_n`, `total`, `profissional` |
| `entrega.sessao.faltou` | ✓ | `sessao_n` |
| `entrega.protocolo.concluido` | — | `dias_totais`, `aderencia_pct` |
| `entrega.protocolo.abandonado` | — | `parou_na_sessao` |
| `entrega.resultado.registrado` | — | `medida`, `foto_url`, `nps` |
| `entrega.indicacao.solicitada` | — | `aceitou` |

### `relacao` — o flywheel
| Código | Cíclico | `dados` |
|---|---|---|
| `relacao.segmento.mudou` | ✓ | `de`, `para`, `gatilho` |
| `relacao.regua.disparada` | ✓ | `regua`, `passo` |
| `relacao.regua.respondida` | ✓ | `regua`, `passo`, `intencao` (bool) |
| `relacao.regua.pausada` | ✓ | `motivo` |
| `relacao.recompra.esperada` | ✓ | `familia`, `ciclo_dias`, `vence_em` |
| `relacao.recompra.atrasada` | ✓ | `familia`, `recencia_relativa` |
| `relacao.indicacao.gerada` | ✓ | `pessoa_indicada_id` |
| `relacao.aniversario` | ✓ | — |
| `relacao.contato.silenciado` | — | `motivo` (opt-out, LGPD) |

**`relacao.indicacao.gerada` fecha o flywheel:** cria uma aresta pessoa → pessoa dentro do próprio banco. Indicação converte 77,8% contra 12,0% do Meta Ads e é 0,6% do topo do funil — com essa aresta registrada, dá para medir pela primeira vez quanto vale um cliente *como fonte de outros clientes*, e não só pelo que ele mesmo compra.

---

## 5. Eventos cíclicos: o que **deveria** ter acontecido

Esta é a peça que faltava. Um lastro que só registra o que aconteceu não enxerga abandono — **abandono é a ausência de um evento esperado**. Por isso a expectativa é uma linha no banco, não um relatório.

```sql
create table expectativa (
  expectativa_id bigserial primary key,
  pessoa_id      bigint not null references pessoa,
  tipo_esperado  text   not null references tipo_evento(codigo),
  origem_evento  bigint references evento,     -- o evento que criou a expectativa
  esperado_em    date   not null,
  janela_dias    int    not null,              -- tolerância antes de virar atraso
  status         text   not null default 'aberta',  -- aberta|cumprida|vencida|cancelada
  cumprido_por   bigint references evento,
  familia        text,                          -- família do procedimento
  criada_em      timestamptz not null default now()
);
create index on expectativa (status, esperado_em);
```

**Como nasce e como morre:**

```
entrega.sessao.realizada (sessão 2 de 4)
        │
        ▼  gera
expectativa: entrega.sessao.realizada, esperado_em = hoje + intervalo
        │
        ├── chega o evento dentro da janela ──▶ status = 'cumprida'
        │
        └── passou da janela ─────────────────▶ status = 'vencida'
                                                       │
                                                       ▼ gera
                                          relacao.recompra.atrasada
                                                       │
                                                       ▼
                                              entra na régua
```

**Os ciclos que alimentam `esperado_em`** — medidos em A3 sobre 490 intervalos reais, p75:

| Família | Ciclo | | Família | Ciclo |
|---|---:|---|---|---:|
| Injetáveis faciais | 164 d | | Suplemento (Morosil) | 53 d |
| Estética facial | 91 d | | Injetáveis corporais | 42 d |
| Criolipólise — protocolo | 72 d | | Endolaser — pós | 36 d |
| Criolipólise | 70 d | | Endolaser | 33 d |
| Drenagem / massagem | 62 d | | *(n < 15 — herda o geral)* | 62 d |

**Quatro expectativas geradas automaticamente:**

| Gatilho | Expectativa criada | Janela |
|---|---|---|
| `lead.criado` | `lead.contato.respondido` | **10 min** (o SLA) |
| `agenda.agendamento.criado` | `agenda.compareceu` | até a data + 1 d |
| `entrega.sessao.realizada` (n < total) | próxima `entrega.sessao.realizada` | intervalo × 1,5 |
| `venda.fechada` | `venda.fechada` seguinte | ciclo da família |

**É isso que transforma segmentação em operação.** A régua não dispara porque alguém rodou um relatório no fim do mês — dispara porque uma expectativa venceu hoje. E a lista de expectativas vencidas *é* a fila de trabalho do dia.

---

## 6. Tags: estado, não fato

Evento é o que aconteceu. Tag é o que a pessoa **é agora**. Confundir os dois é como o `Tags` do Kommo virou lixo — 19,7% de preenchimento misturando o nome do próprio contato ("Binha", "Zenilda") com marcação real (`ANÚNCIO PAGO - META ADS`).

```sql
create table tag (
  tag        text primary key,      -- 'clinico:contraindicacao:gestante'
  namespace  text not null,
  descricao  text not null,
  exclusiva  boolean not null default false,  -- só uma do namespace por vez?
  automatica boolean not null default true    -- derivada de evento, ou manual?
);

create table pessoa_tag (
  pessoa_id  bigint not null references pessoa,
  tag        text   not null references tag,
  desde      timestamptz not null default now(),
  ate        timestamptz,                     -- null = vigente
  origem     bigint references evento,        -- qual evento aplicou
  primary key (pessoa_id, tag, desde)
);
create index on pessoa_tag (pessoa_id) where ate is null;
```

**Tag tem validade.** `ate` é o que permite perguntar "quem estava dormindo em março?" — sem isso, toda análise histórica de segmento é impossível e o banco só sabe o presente.

### Os seis namespaces

| Namespace | Exemplos | Origem |
|---|---|---|
| `origem:` | `origem:meta`, `origem:indicacao`, `origem:organico` | automática, de `lead.criado` |
| `interesse:` | `interesse:criolipolise`, `interesse:endolaser` | automática, da qualificação |
| `clinico:` | `clinico:contraindicacao:gestante`, `clinico:amamentando` | **manual** — decisão clínica |
| `comercial:` | `comercial:sensivel_preco`, `comercial:parcela_sempre` | automática, de motivo de perda e forma de pagamento |
| `relacional:` | `relacional:topo`, `relacional:dormindo`, `relacional:promotor` | automática, do motor de segmentos |
| `operacional:` | `operacional:no_show_recorrente`, `operacional:remarca_sempre` | automática, de padrão na agenda |

**Regras:**

1. **Tag automática nunca é editada à mão.** Se está errada, o evento que a gerou está errado.
2. **Tag manual é só `clinico:`** — é julgamento profissional, não deriva de dado.
3. **Namespace `relacional:` é exclusivo:** uma pessoa está em exatamente um estado relacional por vez.
4. **Nada de tag livre.** Tag fora do catálogo é rejeitada na escrita.

⚠️ `clinico:contraindicacao:*` merece cuidado especial: é dado de saúde, categoria sensível na LGPD. Acesso restrito, e nunca sai para ferramenta de marketing. O caso da Débora — que adiou por estar amamentando e foi retomada 5 meses depois pelo script genérico de reativação — é exatamente o erro que essa tag evita.

---

## 7. As tabelas de estado, em resumo

```sql
create table procedimento (            -- resolve os 72 itens sujos
  procedimento_id serial primary key,
  codigo          text unique not null,
  nome            text not null,
  familia         text not null,       -- as 10 famílias de A1
  ciclo_dias      int  not null,       -- p75 medido em A3
  sessoes_padrao  int  not null default 1,
  gratuito        boolean not null default false   -- separa avaliação de procedimento
);

create table campanha (
  campaign_id text primary key, adset_id text, ad_id text,
  nome text, produto text, investimento numeric(12,2), inicio date, fim date
);

create table oportunidade (            -- o "lead" do Kommo, com funil de verdade
  oportunidade_id bigserial primary key,
  pessoa_id  bigint not null references pessoa,
  funil      text not null,            -- aquisicao | conversao
  etapa      text not null,
  aberta_em  timestamptz not null, fechada_em timestamptz,
  resultado  text,                     -- ganho | perdido
  motivo     text,                     -- lista fechada
  campanha_id text references campanha,
  ctwa_clid  text                      -- o elo anúncio ↔ pessoa
);

create table agendamento (
  agendamento_id  bigserial primary key,
  pessoa_id       bigint not null references pessoa,
  procedimento_id int references procedimento,
  protocolo_id    bigint,              -- preenchido quando é sessão de protocolo
  marcado_em      timestamptz not null,
  agendado_para   timestamptz not null,
  status          text not null,       -- agendado|confirmado|compareceu|no_show|cancelado|remarcado
  origem_id       bigint references agendamento,   -- cadeia de remarcação
  profissional    text,
  motivo_cancelamento text
);

create table venda (
  venda_id bigserial primary key,
  pessoa_id bigint not null references pessoa,
  agendamento_id bigint references agendamento,    -- o elo que falta hoje
  data date not null,
  valor_total numeric(12,2) not null,
  forma_pagamento text, parcelas int, desconto_pct numeric(5,2),
  vendedor text
);

create table venda_item (
  venda_item_id bigserial primary key,
  venda_id bigint not null references venda,
  procedimento_id int not null references procedimento,
  qtd int not null default 1,
  valor_unitario numeric(12,2) not null
);

create table protocolo (
  protocolo_id bigserial primary key,
  pessoa_id bigint not null references pessoa,
  venda_id  bigint references venda,
  procedimento_id int not null references procedimento,
  total_sessoes int not null, sessoes_feitas int not null default 0,
  iniciado_em date, concluido_em date,
  status text not null default 'aberto'   -- aberto|concluido|abandonado
);

create table segmento_dia (            -- snapshot diário: histórico do motor
  dia date not null,
  pessoa_id bigint not null references pessoa,
  estagio text not null,               -- eixo 1
  faixa_valor text not null,           -- eixo 2
  recencia_relativa numeric(6,2),      -- eixo 3
  segmento text not null,
  ltv numeric(12,2), compras_pagas int, ultima_familia text,
  primary key (dia, pessoa_id)
);
```

**Sessão não é tabela.** Uma sessão de protocolo **é** um agendamento com `protocolo_id` preenchido — mesmo ciclo de vida, mesmo no-show, mesma confirmação. Criar uma tabela separada duplicaria a máquina de estados inteira.

⚠️ **`venda_item` resolve a armadilha do valor de linha.** Hoje uma linha com vários itens tem um valor único, e atribuir esse valor a cada item infla a receita por produto — por isso o `mapa_de_dados` avisa que a coluna "serve para ranquear, não para somar". Com `valor_unitario` por item, receita por procedimento passa a somar certo pela primeira vez.

---

## 8. As três consultas que justificam o modelo

### O lastro de uma pessoa, do primeiro clique até hoje

```sql
select e.ocorrido_em, e.tipo, e.ator, e.canal, e.valor, e.dados
from   evento e
join   identidade i on i.pessoa_id = e.pessoa_id
where  i.tipo = 'telefone8' and i.valor = '99654384'
order  by e.ocorrido_em;
```

Uma linha por toque, em ordem, com quem fez e por qual canal. **É a pergunta que hoje exige abrir três planilhas e um zip de WhatsApp.**

### A fila de trabalho de hoje

```sql
select p.nome, x.tipo_esperado, x.esperado_em, x.familia,
       current_date - x.esperado_em as dias_atraso
from   expectativa x join pessoa p using (pessoa_id)
where  x.status = 'aberta'
  and  current_date > x.esperado_em + x.janela_dias
order  by dias_atraso desc;
```

Não é relatório: é a lista do dia. Quem passou do SLA de 10 minutos, quem não compareceu, quem tem sessão atrasada, quem passou do ciclo de recompra — tudo na mesma fila, ordenada pela urgência real.

### O funil de verdade, por campanha

```sql
select c.nome,
       count(distinct o.pessoa_id) filter (where o.funil='aquisicao')          as leads,
       count(distinct a.pessoa_id) filter (where a.status='compareceu')        as compareceram,
       count(distinct v.pessoa_id)                                             as compraram,
       sum(v.valor_total)                                                      as receita,
       sum(v.valor_total) / nullif(max(c.investimento),0)                      as roas
from   campanha c
left   join oportunidade o on o.campanha_id = c.campaign_id
left   join agendamento  a on a.pessoa_id  = o.pessoa_id
left   join venda        v on v.pessoa_id  = o.pessoa_id
group  by c.nome order by roas desc nulls last;
```

**Esta consulta é hoje impossível.** As três abas de Meta Ads são agregados por campanha, produto e faixa etária, e não existe campo que ligue um anúncio a um contato. Com `ctwa_clid` gravado em `oportunidade`, ela passa a rodar — e a decisão de verba deixa de ser inferência por rótulo.

---

## 9. Ingestão: como Kommo e Meta viram entrada

```
Kommo  ──┐
Meta   ──┼──▶ staging_bruto ──▶ resolver identidade ──▶ evento ──▶ projetar estado
Agenda ──┘      (payload cru)      (§3, hierarquia)    (append)     (upsert)
```

| Fonte | O que traz | Frequência | Idempotência |
|---|---|---|---|
| **Kommo** | leads, etapas, movimentação, mensagens | webhook + varredura diária | `kommo:{lead_id}:{evento}` |
| **Meta** | campanhas, custo, `ctwa_clid` | diária | `meta:{ad_id}:{data}` |
| **Agenda** | agendamentos, status, sessões | webhook ou export diário | `agenda:{id_agendamento}:{status}` |
| **Histórico** | a xlsx consolidada, até 25/12/2025 | uma vez | `hist:{fonte}:{linha}` |

**Regras:**

1. **`staging_bruto` guarda o payload íntegro.** Erro de transformação se corrige reprocessando, sem voltar à fonte.
2. **Evento sem pessoa resolvida vai para quarentena**, não para o lastro. Fila de revisão manual.
3. **Carga histórica usa os mesmos tipos de evento.** Os dados até 25/12/2025 entram com `ocorrido_em` real e `registrado_em` = data da carga — o lastro fica contínuo, sem fronteira artificial.
4. **Nada escreve direto em tabela de estado.** Estado é sempre projeção de evento; a única exceção é `procedimento` e `campanha`, que são cadastro.

### Se o destino não for Postgres

| Destino | O que muda | Veredito |
|---|---|---|
| **BigQuery** | `jsonb` → `JSON`; sem FK (só convenção); particionar `evento` por `ocorrido_em`; `expectativa` vira tabela materializada recalculada | Funciona. Melhor se o volume explodir; pior para a fila operacional do dia. |
| **Planilha** | Não suporta o lastro. `evento` chega a ~50 mil linhas no primeiro ano só de histórico | **Não recomendado.** Reproduz o problema que o projeto existe para resolver. |
| **Nativo do CRM** | Depende de o Kommo expor eventos com timestamp e campo livre | Só como paliativo. É o que já falhou. |

---

## 10. Volume esperado — e por que "enxuta" é o adjetivo certo

Estimativa sobre a base atual (6.374 contatos, 1.423 atendimentos, 17 meses):

| Tabela | Linhas na carga histórica | Crescimento anual |
|---|---:|---:|
| `pessoa` | ~6.400 | ~4.500 |
| `identidade` | ~13.000 | ~9.000 |
| **`evento`** | **~45.000** | **~120.000** |
| `expectativa` | ~8.000 | ~25.000 |
| `agendamento` | 0 *(não existe hoje)* | ~6.000 |
| `venda` / `venda_item` | 893 / ~1.900 | ~1.500 / ~3.200 |
| `segmento_dia` | 365 × pessoas ativas | ~1,5 M |

**Nada aqui é grande.** É um Postgres pequeno. Catorze tabelas, trinta e quatro tipos de evento, seis namespaces de tag. A complexidade está na disciplina de emitir o evento certo na hora certa — não no banco.

⚠️ `segmento_dia` é a única tabela que cresce rápido. Se incomodar: guardar só quando o segmento **muda**, em vez de todo dia. O evento `relacao.segmento.mudou` já carrega essa informação — a tabela é conveniência de consulta, não fonte de verdade.

---

## 11. O que este modelo ainda não resolve

- **Não recupera atribuição do passado.** `ctwa_clid` vale a partir do dia em que for ligado. As 55 campanhas já rodadas seguem sem vínculo por pessoa.
- **Não transcreve os 287 áudios.** O lastro registra que houve uma mensagem de áudio às 14h32; o argumento de venda dentro dela continua fora do banco.
- **Não substitui o `agenda.compareceu`.** Enquanto o sistema de agendamento não entregar status, seis dos trinta e quatro tipos de evento ficam vazios — e são justamente os que fecham a métrica-mãe.
- **Não inventa o `ator` retroativamente.** Na carga histórica, `ator` vem nulo em quase tudo. Análise por atendente começa do zero, no dia um.
