# 04 — Mapa de Junções: como as fontes se conectam

Este documento define **a chave canônica do projeto**, mede a taxa real de sucesso de cada junção, e lista o que não dá para cruzar hoje.

---

## 1. A chave canônica: telefone normalizado

Nenhuma fonte tem um identificador comum. O telefone é o que mais se aproxima — mas cada fonte o escreve de um jeito:

| Fonte | Formato bruto | Observação |
|---|---|---|
| CRM Kommo (CSV) | `'+5527992387855` | Apóstrofo à frente (proteção de texto do Excel) |
| `Clientes Unificados` | `+55 (27) 99920-8977` | Parênteses e hífen comum |
| `Vendas Detalhadas` | `+55 (33) 99900-4639` | Idem — **100% preenchido** |
| Nome de arquivo do WhatsApp | `+55 27 99654‑3844` | **Hífen tipográfico U+2011**, não hífen comum |

### Normalização obrigatória
```
1. Remover tudo que não é dígito     →  5527992387855
2. Tomar os 8 últimos dígitos         →  92387855
3. Comparar por esse fragmento
```

**Por que 8 dígitos e não o número inteiro:** o Brasil adicionou o nono dígito aos celulares em momentos diferentes por região, e as fontes têm registros de épocas distintas. Comparar o número completo faz o mesmo cliente aparecer duas vezes. Os 8 últimos são estáveis.

**Por que não menos de 8:** com 7 dígitos a colisão entre pessoas diferentes deixa de ser desprezível numa base de 6.374 contatos.

Esta é a mesma hierarquia que a consolidação anterior já usou e documentou na aba `Auditoria` — foi reconferida e mantida.

### Hierarquia de chaves

| Prioridade | Chave | Confiança | Cobertura |
|---|---|---|---|
| 1 | **CPF** (só dígitos) | Máxima — sem falso positivo | 7,6% no CRM · quase total no cadastro |
| 2 | **Telefone, 8 últimos dígitos** | Alta | 85,6% no CRM · 100% em `Vendas Detalhadas` |
| 3 | **Nome completo, 2+ palavras, normalizado** | Média — usar só como último recurso | 97,1% mas sujo |

**Nome de uma palavra só é descartado como chave.** A base tem dezenas de "Gabriela", "Jéssica", "Karla" — e também `.`, `...` e apelidos ("Binha", "Duda"). O risco de falso positivo é alto demais.

Resultado da hierarquia sobre os 991 clientes do cadastro:

| Chave que resolveu o match | Clientes |
|---|---:|
| Telefone | 596 |
| CPF | 204 |
| Nome completo | 5 |
| *(sem match)* | 186 |

A coluna `Chave de Match CRM` de `Clientes Unificados` **registra qual chave foi usada em cada linha** — toda junção herdada é auditável individualmente.

---

## 2. As junções possíveis e sua taxa real

```
                    ┌──────────────────┐
                    │  Meta Ads        │   55 campanhas · R$ 31.981,35
                    │  (3 abas)        │   6.620 conversas
                    └────────┬─────────┘
                             │  ✗  SEM JUNÇÃO POR PESSOA
                             │     (só agregado por canal e produto inferido)
                    ┌────────┴─────────┐
                    │  CRM Kommo       │   6.374 contatos
                    │  Contatos CRM    │
                    └───┬──────────┬───┘
        telefone/CPF/   │          │  telefone (nome do arquivo)
        nome            │          │
                    ┌───┴──────┐   │      29 de 35 conversas → 83%
                    │ Clientes │   └──────────────┐
                    │Unificados│                  │
                    │   991    │       ┌──────────┴─────────┐
                    └───┬──────┘       │  WhatsApp          │  35 conversas
       805/991 = 81,2%  │              │  ~4.472 mensagens  │
                        │              └────────────────────┘
                    ┌───┴──────────────┐
                    │ Vendas Detalhadas│   1.423 atendimentos
                    │  (telefone 100%) │   681 telefones distintos
                    └──────────────────┘
```

### 2.1 CRM ↔ Cadastro de clientes — **81,2%**

**805 de 991 clientes** têm vínculo com pelo menos um contato do CRM.

Cobertura por recorte:
- Clientes novos abr–dez/2025: **356 de 371 (96%)** — e 97% da receita do período
- Base histórica completa: 81,2%

Os 186 sem match são majoritariamente clientes anteriores a abril/2025, quando o CRM começou a ser usado. **Não é falha de match — é ausência de registro.**

### 2.2 Cadastro ↔ Vendas — **~100%**

Junção interna à planilha, já resolvida e conferida: soma bate exatamente em R$ 805.879,35 e a contagem em 1.423. `Vendas Detalhadas` tem telefone em 100% das linhas, com 681 telefones distintos para 683 nomes de cliente — a diferença de 2 é o efeito de nomes distintos compartilhando telefone (provável parentesco ou recadastro).

### 2.3 WhatsApp ↔ CRM — **83% da amostra**

Das 35 conversas únicas, 31 trazem o telefone no nome do arquivo e **29 casam com um contato no CRM**.

As 4 restantes são nomeadas por pessoa (`Ana Flavia`, `Danielly d'Lucas`, `Mara Cristina Cliente Serra`, `Valdirene Cavatti Cliente Serra`) e só podem ser ligadas por nome — junção fraca. Ironicamente são algumas das conversas mais longas do corpus (381 e 291 mensagens).

⚠️ 83% é a taxa **sobre a amostra**, não sobre a base. As 35 conversas são 0,55% dos contatos.

### 2.4 Meta Ads ↔ qualquer coisa — **✗ impossível por pessoa**

Nenhuma junção. As três abas de Meta Ads são agregados por campanha, produto e faixa etária. **Não existe campo que ligue um anúncio a um contato.**

A atribuição hoje existente é **inferência por rótulo**: o contato tem `Origem = META ADS`, logo a receita dele é creditada ao Meta Ads. Isso responde "quanto o Meta Ads gerou" (R$ 274.613,30), mas **não responde "qual campanha gerou"** — que é a pergunta que decide verba.

Ver §5 para o único vestígio aproveitável.

---

## 3. Riscos de match — o que pode dar errado

| Risco | Evidência real no dado | Mitigação |
|---|---|---|
| **Ordem de nome invertida** | CRM: `Vidal Ludimylla` · Cadastro: `Ludimylla dos Santos Vidal` — mesma pessoa, match por nome falharia | Só usar nome depois de CPF e telefone; comparar conjuntos de tokens, não a string |
| **Nome de uma palavra** | `Gabriela`, `Débora`, `Carol`, `Larissa`, `Mari` no CRM | Descartado como chave (regra herdada da `Auditoria`) |
| **Lixo no campo nome** | `.`, `...`, `Binha`, `Duda` | Filtrar antes de qualquer uso |
| **Emoji no nome** | `Eline Camilo⚖️⚔️` | Normalizar removendo não-letras |
| **Cliente em mais de um canal** | **56 clientes (8%)**, contados em cada canal | As colunas de `Canais de Aquisição` somam mais que o total — nunca somar a coluna inteira |
| **Contato duplicado no CRM** | `Qtd Contatos no CRM` > 1 em vários clientes | Ao agregar receita a partir de `Contatos CRM`, há dupla contagem (R$ 767.056,05 ≠ receita) |
| **Cadastro duplicado** | 1 mesclado na consolidação; 200 linhas marcadas `Registro Mesclado` | Já tratado; conferir ao reprocessar |
| **Telefone reaproveitado** | 683 nomes para 681 telefones em `Vendas` | Baixo impacto, mas existe |
| **Grão diferente entre abas** | Meta Ads: 245 compradores em `Canais` vs 174 clientes pagantes em `Clientes Unificados` | Não são erros — são contagens de coisas diferentes (contato vs. cliente). Nunca misturar numa mesma conta |

---

## 4. Regras de precedência quando as fontes divergem

| Campo | Fonte de verdade | Por quê |
|---|---|---|
| **Receita, valor, ticket** | `Vendas Detalhadas` → agregado em `Clientes Unificados` | É a única que soma R$ 805.879,35. `Contatos CRM` tem dupla contagem |
| **Data de nascimento / idade** | `Clientes Unificados` (cadastro da clínica) | 88% de preenchimento contra 8% no CRM |
| **CPF** | `Clientes Unificados` | Quase universal lá, 7,6% no CRM |
| **Telefone** | `Vendas Detalhadas` (100%) → `Clientes Unificados` → CRM | Ordem de preenchimento |
| **Canal de origem** | `Origem Consolidada` + `Tipo de Origem` | Já normalizados; o `Origem` cru do Kommo mistura canal, produto e ação sobre a base |
| **Data de entrada no funil** | `Criado em` do CRM | Único carimbo confiável de entrada |
| **Procedimento de interesse** | `Procedimento Inicial` (CRM) | É declaração de interesse — **não confundir com `Itens` de `Vendas`**, que é o realizado |
| **Nome** | `Clientes Unificados` | O CRM tem apelidos e lixo |

---

## 5. Junções impossíveis hoje — e o que falta para viabilizá-las

| Junção desejada | Falta | Esforço |
|---|---|---|
| **Anúncio/campanha → cliente** | `click_id` ou UTM gravado no contato no momento da criação | Configuração no Kommo + no Meta. **Baixo esforço, altíssimo retorno** |
| **Conversa do Meta → contato do CRM** | 6.620 conversas contra 3.385 contatos — metade não vira registro | Investigar a automação Meta→Kommo. É o maior vazamento medido |
| **Contato → etapa de funil** | Export de *leads* do Kommo (hoje só temos contatos) | Reexportar. **Zero esforço técnico** — só pedir o export certo |
| **Lead → agendamento** | O sistema de agendamento não expõe agenda, só atendimentos realizados | Depende dos dados do novo sistema |
| **Agendamento → comparecimento** | Não existe registro de no-show/cancelamento em fonte nenhuma | Depende do novo sistema |
| **Atendente → resultado** | Nenhuma fonte carrega o atendente real (ver doc 03 §5) | Campo estruturado no CRM |
| **Cliente → satisfação / resultado clínico** | Não existe | Processo novo de pós-venda |

### 5.1 O único vestígio de atribuição por produto: a mensagem do anúncio

A mensagem automática que o anúncio do Meta injeta na conversa **carrega o produto anunciado**:

> "Olá Mayara! Tenho interesse em mais informações sobre a **Crio Turbo**."

Aparece em 11 das 35 conversas. É hoje o **único ponto de todo o conjunto de dados que liga uma pessoa específica a um anúncio específico**.

**Consequência prática:** se o corpus de WhatsApp for reexportado em escala (200 conversas estratificadas, conforme doc 03 §7), essa frase permite construir uma **atribuição parcial por produto no nível da pessoa** — algo que hoje não existe em nenhuma fonte. Não substitui `click_id`, mas é o melhor disponível sem mudar sistema.

---

## 6. Teste de junção executado — 10 clientes rastreados ponta a ponta

Partindo de 10 conversas de WhatsApp com telefone identificável, seguindo até a venda:

| Telefone | CRM | Cadastro | Vendas | Percurso |
|---|---|---|---|---|
| …95174885 | Jackeline Prati · *(sem origem)* · 01/04/2025 | Jackeline Oliveira Prati · 27 anos | 5 atend. · R$ 1.300,00 | ✅ **completo** |
| …96041377 | Vidal Ludimylla · REATIVAÇÕES · 04/04/2025 | Ludimylla dos Santos Vidal · 26 anos | 2 atend. · R$ 200,00 | ✅ **completo** |
| …95079909 | Jhulia Jhulia · META ADS · 16/01/2026 | Jhulia Santos da Silva · 26 anos | nenhuma | ✅ até o cadastro |
| …91459604 | Fernanda de O. Marques · META ADS · 23/06/2026 | — | — | ⛔ contato de 2026 |
| …97403722 | Eline Camilo · META ADS · 29/01/2026 | — | — | ⛔ contato de 2026 |
| …96294757 | Flávia Pirchiner · META ADS · 08/07/2026 | — | — | ⛔ contato de 2026 |
| …97780442 | Juracilda A. P. Domingos · META ADS · 19/06/2026 | — | — | ⛔ contato de 2026 |
| …96543844 | Débora · META ADS · 11/05/2025 | — | — | ✅ correto: nunca veio |
| …92295330 | Douriane · REATIVAÇÕES · 04/04/2025 | — | — | ⚠️ ver §6.2 |
| …97956907 | Nitsa Lima · REATIVAÇÕES · 04/04/2025 | — | — | ⚠️ ver §6.2 |

**3 de 10 completaram o percurso até a venda.** Os demais não falharam por erro de junção — cada ausência tem explicação:

### 6.1 Quatro casos são a janela de dados, não falha de match
Fernanda, Eline, Flávia e Juracilda entraram no CRM em **2026**, depois de 25/12/2025, onde a base de vendas termina. É exatamente a lacuna nº 4 do doc 00, materializada. **Esses quatro serão resolvidos automaticamente quando os dados do novo sistema chegarem.**

O caso da Débora é o oposto: entrou em 05/2025, dentro da janela, e a ausência de venda é o dado correto — a conversa mostra que ela adiou o procedimento por estar amamentando e nunca voltou.

### 6.2 ⚠️ Achado: a "reativação" não está reativando clientes

Douriane e Nitsa Lima têm `Origem = REATIVAÇÕES` e **não existem no cadastro da clínica**. Não é caso isolado — medindo os 1.104 contatos de reativação:

| Origem | Contatos | Existem no cadastro | % |
|---|---:|---:|---:|
| BASE DE CLIENTES | 16 | 15 | **93,8%** |
| INDICAÇÃO DE CLIENTES | 37 | 30 | 81,1% |
| INSTAGRAM ORG | 68 | 40 | 58,8% |
| **REATIVAÇÕES** | **1.104** | **248** | **22,5%** |
| META ADS | 3.385 | 365 | 10,8% |
| *(sem origem)* | 1.747 | 175 | 10,0% |

**77,5% dos contatos marcados como "reativação" nunca foram clientes da clínica.** Ou o rótulo está sendo usado para "lead antigo retrabalhado" — o que é uma coisa bem diferente de reativar cliente — ou a campanha está sendo disparada para uma lista que não é a base.

Isso importa porque a aba `Canais de Aquisição` credita R$ 141.805,40 à Reativação, com LTV de R$ 977,97 e conversão de 13,13%. Se a maior parte desses contatos nunca foi cliente, **"Reativação" não é trabalho sobre a base — é um canal de aquisição fria disfarçado**, e o `Tipo de Origem` que o classifica como "Trabalho sobre a base" está induzindo a leitura errada.

**Ação:** confirmar com a operação o que exatamente entra no rótulo `REATIVAÇÕES` antes de qualquer decisão baseada nesse canal. É a primeira pergunta a fazer ao reestruturar o funil.

### 6.3 O que o teste valida
- A chave de 8 dígitos funcionou em 10 de 10 tentativas contra o CRM — **zero falsos negativos**.
- A junção por nome teria falhado em 2 dos 3 casos completos (`Vidal Ludimylla` ≠ `Ludimylla dos Santos Vidal`; `Jhulia Jhulia` ≠ `Jhulia Santos da Silva`). **Confirma a decisão de rebaixar o nome para último recurso.**
- Nenhum falso positivo observado.

---

## 7. Receita de junção — a ordem recomendada

Para qualquer análise futura que precise da visão completa do cliente:

1. **Comece por `Vendas Detalhadas`** — parseando com o cuidado da vírgula decimal, e confira a soma contra R$ 805.879,35 antes de seguir.
2. **Agregue por telefone (8 dígitos)** para chegar ao nível do cliente — ou use `Clientes Unificados`, que já traz isso pronto e conferido.
3. **Enriqueça com o CRM** pela mesma chave, para trazer `Origem Consolidada`, `Tipo de Origem`, `Procedimento Inicial` e `Criado em`.
4. **Separe as coortes** por `Criado em`: até 25/12/2025 é analisável; depois disso, aguarda os dados novos.
5. **Só então** traga o WhatsApp, ciente de que cobre 0,55% da base e serve para qualificar o *como*, nunca para medir o *quanto*.
6. **Nunca some** colunas de `Canais de Aquisição` nem `Receita do Cliente` de `Contatos CRM`.
