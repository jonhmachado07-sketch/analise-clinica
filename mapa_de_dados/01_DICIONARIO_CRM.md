# 01 — Dicionário do CRM (Kommo)

**Arquivo:** `exportacao_funis_crm/kommo_export_contacts_and_companies_2026-08-07.csv`
**Linhas:** 6.378 (6.374 contatos + 4 empresas) · **Colunas:** 37
**Janela:** 01/04/2025 → 07/08/2026
**Encoding:** UTF-8 · separador vírgula · campos com aspas duplas

---

## 1. O que este arquivo é — e o que ele não é

É um **export de contatos**, não de leads. No Kommo, contato e lead são entidades distintas: o contato é a pessoa, o lead é a negociação. Tudo que define funil — etapa atual, valor da negociação, histórico de movimentação, motivo de perda, tempo em cada etapa — **vive no lead e não veio neste arquivo**.

A única pista de lead é a coluna `Leads`, que traz apenas o rótulo textual (`Lead #23101943`) ou o nome do contato repetido. Não há ID utilizável, etapa, nem valor.

**Consequência prática:** toda conversão neste projeto é reconstruída *a posteriori*, cruzando contato com venda real. Não é medição de funil, é inferência de resultado.

---

## 2. As 37 colunas, campo a campo

Preenchimento medido sobre as 6.378 linhas.

### Identificação e controle

| Coluna | Preench. | Tipo | Significado e armadilhas |
|---|---|---|---|
| `ID` | 100,0% | inteiro | ID do contato no Kommo. **Chave primária confiável.** Ex.: `27874071`. Casa com `ID Contatos CRM` da aba `Clientes Unificados`. |
| `Tipo` | 100,0% | categórico | `contato` (6.374) ou `empresa` (4). **Filtrar `empresa` fora de qualquer análise de cliente.** |
| `Nome completo` | 97,1% | texto | Sujo: contém `.`, `...`, apelidos ("Binha", "Duda"), e nomes de uma palavra só. **Não usar como chave de match sem exigir 2+ palavras.** |
| `Primeiro nome` | 71,5% | texto | Derivado, frequentemente igual ao nome completo. |
| `Sobrenome` | 29,2% | texto | Baixa cobertura — reforça que o nome não serve de chave. |
| `Nome da empresa` | 0,1% | texto | Só as 4 linhas de tipo `empresa`. Irrelevante. |
| `Criado em` | 100,0% | data-hora | `dd.mm.aaaa hh:mm:ss`. **O carimbo mais confiável do arquivo** — define a coorte de entrada e a janela comparável. |
| `modificada em` | 65,2% | data-hora | Última alteração. Vazio = nunca tocado desde a criação — sinal de contato abandonado. |
| `Criado por` | 19,0% | texto | Baixo preenchimento porque a maioria entra por automação (Meta Ads → CRM). Vazio ≈ origem automática. |
| `Modificado por` | 85,3% | texto | Quase sempre `Welton Machado`. |
| `Usuário responsável` | 89,5% | texto | Quase monocolor (`Welton Machado`). **Não serve para analisar desempenho por atendente** — a operação real tem várias pessoas (ver `03_DICIONARIO_WHATSAPP.md` §5). |
| `Leads` | 100,0% | texto | Rótulo do lead vinculado (`Lead #23101943`) ou nome repetido. **Sem etapa, sem valor, sem ID utilizável.** |
| `Termos do usuário` | 99,9% | categórico | Praticamente sempre `Não`. Consentimento/LGPD não está sendo capturado de fato. |

### Contato

| Coluna | Preench. | Tipo | Significado e armadilhas |
|---|---|---|---|
| `Telefone comercial` | 85,6% | texto | **É o celular real do cliente**, apesar do nome do campo. Formato `'+5527992387855` — com apóstrofo à frente (proteção de texto do Excel), a remover no parsing. **Chave de match nº 2.** |
| `Email comercial` | 8,2% | texto | Idem: é o e-mail pessoal, sob rótulo errado. |
| `Tel. direto com.`, `Celular`, `Fax`, `Telefone residencial`, `Outro telefone` | **0,0%** | — | Campos existentes e integralmente vazios. |
| `Email pessoal`, `Outro email`, `Site`, `Endereço` | **0,0%** | — | Idem. |

⚠️ Os campos "corretos" (`Celular`, `Email pessoal`) estão vazios e os dados reais moram nos campos "comerciais". Quem consultar o CRM pelo nome do campo lê zero.

### Dados do cliente

| Coluna | Preench. | Tipo | Significado e armadilhas |
|---|---|---|---|
| `CPF` | 7,6% | texto | **A chave de match mais forte é a mais rara.** Só 485 contatos. |
| `Nascimento` | 8,0% | data | 508 contatos. Inviabiliza análise etária pelo CRM — a faixa etária confiável vem do cadastro da clínica (aba `Clientes Unificados`) ou do Meta Ads. |
| `Cargo` | 7,0% | texto | Usado de forma não padronizada; baixa utilidade. |
| `Cidade` | 55,0% | texto | 3.509 contatos. Predominância de `Serra-ES`. **Utilizável para análise geográfica com ressalva de cobertura.** |
| `Bairro` | 6,0% | texto | 384 contatos. Insuficiente para microssegmentação geográfica. |
| `Tags` | 19,7% | texto | Uso inconsistente: às vezes o próprio nome do contato ("Binha", "Zenilda"), às vezes marcação real (`ANÚNCIO PAGO - META ADS`). **Campo poluído — não confiar sem limpeza.** |
| `Nota 1` … `Nota 5` | **0,0%** | — | Cinco campos de anotação, todos vazios em 6.378 linhas. Nenhum contexto qualitativo do lead está sendo registrado de forma estruturada. |
| `CNPJ` | — | — | Vazio. |

### Marketing — os dois campos que sustentam a análise

| Coluna | Preench. | Tipo | Significado |
|---|---|---|---|
| `Origem` | 72,5% | categórico | Canal de entrada. **O campo mais importante do arquivo.** 1.751 vazios (27,5%). |
| `Procedimento Inicial` | 75,8% | categórico | Produto de interesse declarado na entrada. Base de toda análise de demanda por produto. |

---

## 3. Distribuição de `Origem`

| Valor | Contatos | % | Natureza |
|---|---:|---:|---|
| `META ADS` | 3.385 | 53,1% | Aquisição paga |
| *(vazio)* | 1.751 | 27,5% | **Cego** |
| `REATIVAÇÕES` | 1.104 | 17,3% | Trabalho sobre a base — **não é aquisição** |
| `INSTAGRAM ORG` | 68 | 1,1% | Aquisição orgânica |
| `INDICAÇÃO DE CLIENTES` | 37 | 0,6% | Aquisição — melhor conversão de todas (77,8%) |
| `BASE DE CLIENTES` | 16 | 0,3% | Trabalho sobre a base |
| `MEU NEGÓCIO` | 8 | 0,1% | Google Meu Negócio |
| `SITE_CRIOLIPÓLISE` | 5 | 0,1% | Site, com produto no rótulo |
| `SITE_ENDOLASER` | 3 | 0,0% | Idem |
| `GOOGLE ADS` | 1 | 0,0% | Canal praticamente inexistente |

**Leituras:**
- Os valores de `Origem` misturam **canal** (`META ADS`) com **produto** (`SITE_CRIOLIPÓLISE`) e com **ação sobre a base** (`REATIVAÇÕES`). Não é uma taxonomia limpa. A aba `Clientes Unificados` já corrige isso separando `Origem Consolidada` de `Tipo de Origem`.
- Os 27,5% vazios são o ponto cego mais barato de fechar: é um campo obrigatório no formulário de criação do contato, não um dado que precise ser comprado.
- `INDICAÇÃO` tem 37 contatos e 77,8% de conversão. É o melhor canal da clínica e o menos alimentado — 0,6% do topo do funil.

---

## 4. Distribuição de `Procedimento Inicial`

| Valor | Contatos |
|---|---:|
| Criolipólise | 2.836 |
| Endolaser | 1.633 |
| *(vazio)* | 1.544 |
| Preenchimento | 239 |
| Aplicação de Enzimas | 58 |
| BOTOX | 25 |
| EndoShape | 18 |
| Limpeza de Pele | 13 |
| Glúteo Max | 5 |
| Bioestimulador | 3 |
| Rinomodelação · Clareamento Facial · Avaliação_Criolipólise · Crio Full Face | 1 cada |

**Leituras:**
- Duas famílias de produto concentram **70%** da demanda declarada: Criolipólise e Endolaser. Isso espelha a alocação de verba no Meta Ads (58,8% + 23,3% = 82,1%) — a demanda de entrada é, em boa medida, um reflexo do que se anuncia.
- A cauda longa (Botox, Bioestimulador, Preenchimento) tem pouca demanda declarada na entrada **mas altíssimo valor por atendimento** nas vendas (ver `02_DICIONARIO_BASE_UNIFICADA.md` §5). É um descasamento estrutural: anuncia-se o produto de entrada barato e vende-se o caro depois, sem que isso seja medido.
- ⚠️ `Procedimento Inicial` é **interesse declarado, não procedimento realizado**. Cruzá-lo com `Itens` de `Vendas Detalhadas` mede migração de interesse — não é o mesmo campo em dois lugares.

---

## 5. Campos que existem mas estão vazios — o custo de oportunidade

| Campo | Preench. | O que se perde |
|---|---|---|
| `Nota 1..5` | 0% | Todo o contexto qualitativo do lead: objeção declarada, motivo de perda, condição de saúde, expectativa. Está tudo em conversa de WhatsApp, não estruturado. |
| `Email pessoal` / `Outro email` | 0% | Canal de reativação de custo zero. Hoje só 8,2% tem e-mail, e no campo errado. |
| `Endereço` | 0% | Análise de raio de deslocamento até a clínica — determinante em estética, onde o cliente volta várias vezes. |
| `CPF` | 7,6% | A chave de match forte. Com CPF universal, a junção CRM↔vendas iria a ~100% em vez de 81,2%. |
| `Nascimento` | 8,0% | Segmentação etária direto no CRM, hoje só possível via cadastro da clínica. |
| `Bairro` | 6,0% | Microssegmentação geográfica e escolha de raio de anúncio. |
| `Termos do usuário` | 99,9% = `Não` | Base legal para comunicação. Risco de LGPD numa base de 6.374 pessoas. |

Nenhum desses campos exige sistema novo. Todos são preenchimento operacional no cadastro que já existe.

---

## 6. O que este export NÃO traz

Ausências confirmadas — não é questão de procurar melhor:

- **Etapa de funil atual** do lead
- **Histórico de movimentação** entre etapas e **timestamp de cada mudança**
- **Tempo de permanência** em cada etapa
- **Valor da negociação** (o "quanto vale este lead")
- **Motivo de perda** / status ganho-perdido
- **Tarefas e follow-ups** agendados ou executados
- **Responsável por etapa** (só há um responsável global do contato)
- **UTM, `click_id`, ID de anúncio ou campanha** — nada que ligue o contato ao anúncio que o gerou
- **Mensagens** — o CRM está conectado ao WhatsApp, mas o histórico de conversa não veio neste export

As quatro primeiras são o bloqueio direto para reestruturar o funil. A oitava é o bloqueio direto para decidir verba de mídia.

**O que pedir na próxima exportação do Kommo:** o export de **leads** (`pipelines`/`leads`), com etapa, valor, data de entrada em cada etapa, status e motivo de perda — além do export de contatos que já temos.

---

## 7. Relação com a aba `Contatos CRM` da xlsx

A aba `Contatos CRM` da base unificada é **este mesmo arquivo, enriquecido**: mantém 15 das 37 colunas e acrescenta `Virou Cliente`, `Cliente na Base` e `Receita do Cliente (R$)`.

**Para análise, use a aba** — ela já traz o cruzamento com venda pronto (883 contatos marcados `Virou Cliente = Sim`).
**Volte a este CSV quando precisar** de: `Tags`, `Cargo`, `Criado por`, `modificada em`, `Modificado por`, `Termos do usuário`, ou confirmar que um campo está de fato vazio.
