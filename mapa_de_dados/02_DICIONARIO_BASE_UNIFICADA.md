# 02 — Dicionário da Base Unificada (sistema de agendamento)

**Arquivo:** `exportacao_sistemas_agendamento/Base Unificada - Clinica Expert.xlsx`
**8 abas** · gerado em LibreOffice Calc · export de 07/08/2026

---

## 0. Antes de tudo: esta planilha é um produto derivado

Não é o dump bruto do sistema de agendamento. É o resultado de um trabalho anterior de consolidação que cruzou **quatro fontes**: cadastro de pacientes da clínica, vendas/atendimentos, contatos do CRM Kommo e relatórios do Meta Ads. A aba `Auditoria` documenta a chave de match usada e as limitações conhecidas.

Este mapa **absorve** esse trabalho. As conferências dele foram reproduzidas e batem (§8).

Onde a planilha não alcança, é porque o dado não existia na origem — não porque foi mal consolidado.

---

## ⚠️ 1. A armadilha numérica mais importante do projeto

**Todos os números desta planilha estão gravados como texto**, e **abas diferentes usam separadores decimais diferentes**:

| Aba | Formato do valor | Exemplo |
|---|---|---|
| `Vendas Detalhadas` | **vírgula** decimal | `2499,9` |
| `Clientes Unificados` | **ponto** decimal | `7849.9` |
| `Contatos CRM` | ponto decimal | `1108.59` |
| `Canais de Aquisição`, abas Meta Ads | ponto decimal | `271605.4` |

Um parser de cultura fixa erra em pelo menos uma das abas. Lendo `Vendas Detalhadas` com ponto decimal, `2499,9` vira `24999` e a receita total sai **R$ 1.823.364,00** em vez de **R$ 805.879,35** — inflada em 2,26×.

**Regra:** se a string contém vírgula, parsear como `pt-BR`; senão, como invariante. **Toda análise começa conferindo a soma contra R$ 805.879,35.**

Datas são texto `dd/mm/aaaa` em todas as abas — não são seriais do Excel.

---

## 2. Aba `Clientes Unificados` — 991 clientes × 158 colunas

**Grão:** um cliente (pessoa física cadastrada na clínica).
**Chave:** `Nome` + `Telefone` + `CPF`. Sem ID próprio.
**Nota:** 992 linhas na origem, **1 duplicata mesclada** → 991 clientes únicos.

A aba é larga porque **achata o histórico transacional em colunas**. Lê-se em cinco blocos:

### Bloco A — Cadastro (col. 1–16)
`Nome` · `Tipo` · `Tags` · `Telefone` · `E-mail` · `Ativo` · `Data de nascimento` · `Idade` · `Sexo` · `Estado civil` · `Profissão` · `Endereço` · `CPF` · `RG` · `CNPJ` · `Cor`

Vem do cadastro da clínica. **É mais rico que o CRM**: `Idade` preenchida em 875 de 991 (88%) contra 8% no Kommo; CPF quase universal aqui e 7,6% lá.

Perfil resultante: **891 mulheres, 55 homens, 45 sem informação** — 94% do público é feminino. Idade mediana **39 anos**, quartis 32 e 46.

### Bloco B — Origem e vínculo com o CRM (col. 17–30)
`Origem` · `Origem Consolidada` · `Tipo de Origem` · `Fonte da Origem` · `Origem CRM` · `Procedimento Inicial CRM` · `Cidade CRM` · `Bairro CRM` · `Tags CRM` · `Nascimento CRM` · `Qtd Contatos no CRM` · `Entrou no CRM em` · `ID Contatos CRM` · `Chave de Match CRM`

Este bloco é o **coração do mapa**. Ele resolve a bagunça taxonômica do campo `Origem` do Kommo (que mistura canal, produto e ação sobre a base) em três eixos limpos:

- **`Origem Consolidada`** — o canal normalizado.
- **`Tipo de Origem`** — `Canal de aquisição` (460) · `Trabalho sobre a base` (226) · `Não informado` (305). **Este campo é o que impede somar reativação como se fosse aquisição.**
- **`Fonte da Origem`** — de onde veio a informação: `CRM Kommo` (667) · `Cadastro clínica` (19) · `—` (305). Permite saber o quanto se está confiando no CRM.

**`Chave de Match CRM`** registra *como* o cliente foi ligado ao CRM — auditável linha a linha:

| Chave usada | Clientes | Confiança |
|---|---:|---|
| Telefone (8 últimos dígitos) | 596 | Alta |
| CPF | 204 | Máxima |
| Nome completo (2+ palavras) | 5 | Média |
| *(sem match)* | 186 | — |

**805 de 991 clientes (81,2%)** têm vínculo com algum contato do CRM.

### Bloco C — Agregados de compra (col. 31–48)
`Convênio` · `Tem Venda (2024/2025)` · `Qtd Compras` · `Valor Total (R$)` · `Ticket Médio (R$)` · `Primeira Compra` · `Última Compra` — e o mesmo conjunto repetido para 2024 e 2025.

**Use este bloco para qualquer análise de LTV, recompra ou coorte.** Já está calculado e confere com a fonte.

⚠️ `Tem Venda = Sim` (683 clientes) significa **teve atendimento registrado**, não que pagou. Ver §5.

### Bloco D — Histórico alinhado (col. 49–54)
`Anos` · `Datas` · `Valores` · `Itens` · `Descrições` · `Responsáveis (alinhado)`

Seis listas paralelas separadas por ` | `, uma posição por atendimento, em ordem cronológica. É a forma mais compacta de ler a **jornada** de um cliente:

```
Datas:   29/08/2024 | 10/09/2024 | 14/10/2024 | 01/11/2024 | ...
Valores: 150.0      | 350.0      | 250.0      | 1000.0     | ...
Itens:   Glúteo Maxx| 3x ENZIMAS | Glúteo+ENZ | ENDOLASER  | ...
```

**Para estudar sequência típica de procedimentos, este é o bloco certo** — a posição *n* de cada lista se refere ao mesmo atendimento.

### Bloco E — Vendas explodidas `V1..V17` (col. 55–156)
17 grupos de 6 colunas: `Vn Ano` · `Vn Data` · `Vn Valor (R$)` · `Vn Itens` · `Vn Descrição` · `Vn Responsável`.

É o mesmo conteúdo do bloco D, desdobrado em colunas para uso em planilha. **17 é o máximo observado** (a cliente Marlene Cardoso Loiola, 17 atendimentos entre 08/2024 e 12/2025).

**Redundante com D e com a aba `Vendas Detalhadas`.** Para análise programática, prefira `Vendas Detalhadas` (formato longo, um atendimento por linha). Use `V1..V17` apenas para inspeção manual.

### Col. 158 — `Registro Mesclado (duplicata)`
Marcado em 200 linhas — indica cliente cujo registro absorveu um duplicado. Não confundir com a "1 duplicata mesclada" da `Auditoria`, que se refere à contagem 992→991.

### Distribuição de recompra

| Qtd de atendimentos | Clientes |
|---|---:|
| 0 | 308 |
| 1 | 357 |
| 2–3 | 236 |
| 4–5 | 57 |
| 6–10 | 28 |
| 11+ | 5 |

**357 clientes vieram uma única vez** — o maior bloco depois dos que nunca vieram. É o alvo natural de qualquer trabalho de retenção.

**Concentração de receita:** top 20 clientes = 15,8% da receita; top 100 = **45,4%**. Maior cliente: R$ 9.199,90 em 12 compras.

---

## 3. Aba `Vendas Detalhadas` — 1.423 linhas × 24 colunas

**Grão:** um atendimento. **Fonte de verdade financeira do projeto.**

| Col | Campo | Notas |
|---|---|---|
| 1 | `Ano Base` | `2024` (396 linhas) ou `2025` (1.027) |
| 2 | `Data` | `dd/mm/aaaa` — 09/07/2024 a 25/12/2025 |
| 3 | `Descrição` | Sempre `Atendimento de <nome>`. **Campo sem informação** — redundante com `Cliente` |
| 4 | `Cliente` | Nome em CAIXA ALTA. 683 clientes distintos |
| 5 | `Responsável` | **`Mayara Ribeiro Ferreira` em 100% das 1.423 linhas.** Ver §6 |
| 6 | `Valor` | ⚠️ vírgula decimal. Soma = R$ 805.879,35 |
| 7 | `Itens` | Procedimentos separados por vírgula. 72 itens distintos |
| 8–24 | `Telefone` … `Tags` | Cadastro do cliente repetido em cada linha (desnormalizado). `Telefone` 100% preenchido — **é a chave de junção mais confiável desta aba** |

### Receita por ano

| Ano | Linhas | Receita |
|---|---:|---:|
| 2024 | 396 | R$ 247.066,70 |
| 2025 | 1.027 | R$ 558.812,65 |
| **Total** | **1.423** | **R$ 805.879,35** ✅ |

---

## 4. Aba `Contatos CRM` — 6.374 contatos × 15 colunas

O CSV do Kommo enriquecido, reduzido a 15 colunas úteis e acrescido de três derivadas:

| Campo derivado | Conteúdo |
|---|---|
| `Virou Cliente` | `Sim` em **883** contatos, `Não` em 5.491 |
| `Cliente na Base` | Nome do cliente correspondente no cadastro (preenchido nos 883) |
| `Receita do Cliente (R$)` | Receita do cliente vinculado |

⚠️ **A soma de `Receita do Cliente` NÃO é a receita total.** Dá R$ 767.056,05, mas com dupla contagem: um cliente com dois contatos no CRM aparece duas vezes com a receita inteira. **Para somar receita, use sempre `Clientes Unificados` ou `Vendas Detalhadas`.**

Note também: 883 contatos "viraram cliente" mas só **465** têm receita > 0 — de novo a distinção entre *compareceu* e *pagou*.

Use esta aba para análise; volte ao CSV bruto para `Tags`, `Cargo`, `Criado por`, `Modificado por` e `Termos do usuário` (ver `01_DICIONARIO_CRM.md` §7).

---

## 5. ⚠️ 37% das "vendas" são de valor zero

**530 das 1.423 linhas (37,2%) têm valor R$ 0.** Não são erro — são atendimentos gratuitos:

| Item na linha de valor zero | Ocorrências |
|---|---:|
| AVALIAÇÃO CRIO | 328 |
| AVALIAÇÃO FACIAL | 68 |
| REAVALIAÇÃO FACIAL | 32 |
| Reavaliação | 23 |
| PÓS CRIO | 21 |
| AVALIAÇAO ENDOLASER | 9 |
| CRIO TURBO | 9 |
| Pós endolaser | 8 |
| DRENAGEM LINFÁTICA | 6 |

Isto muda a interpretação de tudo:

- **1.423 não é o número de vendas.** São **893** atendimentos pagos e 530 gratuitos.
- **683 não é o número de compradores.** São **511 clientes pagantes** distintos; os outros 172 vieram, foram atendidos e não geraram receita.
- A `AVALIAÇÃO CRIO` gratuita é, sozinha, **23% de todos os atendimentos da clínica**. É o principal produto de entrada e o principal consumidor de agenda. **Sem dados de agendamento, é impossível saber quantas avaliações viraram procedimento pago** — e essa é a conversão mais importante da operação.
- Um "cliente ativo" que só fez avaliação gratuita não é cliente comercialmente. `Tem Venda = Sim` precisa ser lido junto de `Valor Total > 0`.

**Ticket dos atendimentos pagos:** mínimo R$ 100 · p25 R$ 150 · **mediana R$ 707,90** · p75 R$ 1.500 · p90 R$ 2.000 · máximo R$ 5.000. Distribuição fortemente bimodal — sessões avulsas baratas versus pacotes.

### Receita por item (top 12)

Valor da linha atribuído integralmente a cada item que ela contém — linhas com vários itens contam em todos, então **a coluna de receita soma mais que o total**. Serve para ranquear, não para somar.

| Item | Linhas | Receita atribuída |
|---|---:|---:|
| Cápsula Morosil | 123 | R$ 240.049,90 |
| ENDOLASER | 126 | R$ 209.797,80 |
| 4x Pós endolaser | 90 | R$ 164.841,50 |
| 3x PÓS CRIO | 108 | R$ 150.439,30 |
| PRÉ CRIO | 93 | R$ 144.176,40 |
| CRIOLIPÓLISE AVANÇADA | 78 | R$ 137.445,80 |
| BOTOX | 89 | R$ 122.277,50 |
| Criolipólise 2h | 94 | R$ 83.145,90 |
| PREENCHIMENTO ÁC. HIALURÔNICO | 64 | R$ 75.841,50 |
| 2x PREENCHIMENTO ÁC. HIALURÔNICO | 36 | R$ 56.745,80 |
| BIOESTIMULADOR DE COLÁGENO | 21 | R$ 42.275,85 |
| 2x ENDOLASER | 15 | R$ 42.200,00 |

**Cápsula Morosil aparece no topo e não tem campanha nenhuma no Meta Ads.** É um produto de venda no balcão/conversa, invisível na análise de mídia.

⚠️ **Nomenclatura suja em `Itens`:** 72 valores distintos com quantidade embutida no nome (`3x PÓS CRIO`, `2x ENDOLASER`, `4x Pós endolaser`), caixa inconsistente (`Pós endolaser` vs `PÓS CRIO`), acento faltando (`AVALIAÇAO ENDOLASER`) e variantes do mesmo produto (`Criolipólise 2h`, `CRIO TURBO`, `CRIO FULL 360º`, `CRIOLIPÓLISE AVANÇADA`, `CRIO DINAMIC FLACIDEZ`). **Qualquer análise por produto exige um de-para canônico** — que ainda não existe e deve ser construído antes do estudo de padrões de compra.

---

## 6. Aba `Canais de Aquisição` — 9 linhas

Conversão contato→comprador, receita, LTV e **CAC máximo para empatar**, por canal.

| Canal | Tipo | Contatos | Compradores | Conv. % | Receita | LTV médio | CAC máx./lead |
|---|---|---:|---:|---:|---:|---:|---:|
| Meta Ads | Aquisição | 2.043 | 245 | 11,99% | R$ 271.605,40 | R$ 1.108,59 | R$ 132,94 |
| Não informado | — | 1.007 | 129 | 12,81% | R$ 221.942,10 | R$ 1.720,48 | R$ 220,40 |
| Reativação | Base | 1.104 | 145 | 13,13% | R$ 141.805,40 | R$ 977,97 | R$ 128,45 |
| Indicação | Aquisição | 36 | 28 | **77,78%** | R$ 43.167,90 | R$ 1.541,71 | R$ 1.199,11 |
| Base de Clientes | Base | 16 | 14 | 87,50% | R$ 35.532,15 | R$ 2.538,01 | R$ 2.220,76 |
| Instagram Orgânico | Aquisição | 64 | 33 | **51,56%** | R$ 29.203,60 | R$ 884,96 | R$ 456,31 |
| Google Meu Negócio | Aquisição | 7 | 5 | 71,43% | R$ 3.000,00 | R$ 600,00 | R$ 428,57 |
| Site | Aquisição | 5 | 3 | 60,00% | R$ 1.100,00 | R$ 366,67 | R$ 220,00 |
| Google Ads | Aquisição | 1 | 0 | 0% | R$ 0 | R$ 0 | R$ 0 |

**Como ler o CAC máximo:** é o teto de custo por lead em que o canal ainda empata com o LTV médio. Meta Ads suporta até R$ 132,94 por lead; hoje o custo por conversa é R$ 4,52 — mas conversa não é lead (§7).

**A leitura central desta aba:** os canais de alta conversão são os menores. Indicação converte 6,5× melhor que Meta Ads e responde por 36 contatos contra 2.043. Instagram orgânico converte 4,3× melhor e tem 64. **O funil está sendo alimentado quase inteiramente pelo canal que converte pior.**

⚠️ **Divergências de contagem a conhecer:** esta aba conta no nível de *contato*, enquanto `Clientes Unificados` conta no nível de *cliente*. Para Meta Ads: 245 compradores aqui, 174 clientes pagantes lá; receita R$ 271.605,40 aqui, R$ 274.613,30 lá (este último é o valor que a `Auditoria` usa). **Não são erros, são grãos diferentes** — mas nunca misture os dois números na mesma conta. Para receita, a referência é `Clientes Unificados` / `Vendas Detalhadas`.

⚠️ 56 clientes (8%) aparecem em mais de um canal e são contados em cada um. **As colunas de contato e comprador somam mais que o total real.**

---

## 7. Abas de Meta Ads — investimento e retorno

Três recortes do mesmo relatório (07/07/2023 → 07/08/2026): **R$ 31.981,35** em 55 campanhas, 864 linhas, **6.620 conversas iniciadas**, custo médio por conversa **R$ 4,52**.

### `Meta Ads - Produto`

| Produto | Investimento | Conversas | Custo/conversa | Receita clientes Meta | ROAS | % verba |
|---|---:|---:|---:|---:|---:|---:|
| Criolipólise | R$ 18.793,79 | 4.012 | R$ 4,52 | R$ 131.748,85 | 7,01 | 58,8% |
| Endolaser | R$ 7.466,93 | 1.553 | R$ 4,69 | R$ 99.478,10 | **13,32** | 23,3% |
| Preenchimento | R$ 2.977,16 | 584 | R$ 4,58 | R$ 24.134,39 | 8,11 | 9,3% |
| Intradermoterapia | R$ 454,11 | 153 | R$ 2,90 | R$ 1.600,00 | 3,52 | 1,4% |
| Microvasos | R$ 174,08 | 78 | R$ 2,23 | R$ 399,68 | 2,30 | 0,5% |
| Microagulhamento | R$ 54,46 | 5 | R$ 9,79 | R$ 400,00 | 7,34 | 0,2% |
| Drenagem | R$ 40,72 | 7 | R$ 4,21 | R$ 700,00 | **17,19** | 0,1% |
| Sem campanha | R$ 0 | 0 | — | R$ 16.152,28 | — | 0% |

**Endolaser tem quase o dobro do ROAS da Criolipólise e recebe 2,5× menos verba.** É o achado mais acionável desta aba — e o primeiro a validar quando os dados novos chegarem.

⚠️ Produto **inferido do nome da campanha**; campanhas sem produto explícito caem em "Institucional/marca".

### `Meta Ads - Faixa Etária`

| Faixa | Clientes | Compradores | Receita | LTV | Investimento | % verba | ROAS |
|---|---:|---:|---:|---:|---:|---:|---:|
| 18-24 | 18 | 12 | R$ 11.675,70 | R$ 972,97 | R$ 2.042,78 | 6,8% | 5,72 |
| 25-34 | 103 | 63 | R$ 69.220,90 | R$ 1.098,74 | R$ 8.927,90 | 29,8% | 7,75 |
| 35-44 | 128 | 94 | R$ 97.348,10 | R$ 1.035,62 | R$ 10.548,94 | 35,2% | 9,23 |
| 45-54 | 68 | 49 | R$ 58.833,50 | R$ 1.200,68 | R$ 6.097,07 | 20,4% | 9,65 |
| 55-64 | 26 | 21 | R$ 32.537,20 | **R$ 1.549,39** | R$ 1.802,33 | 6,0% | **18,05** |
| 65+ | 4 | 3 | R$ 2.300,00 | R$ 766,67 | R$ 527,05 | 1,8% | 4,36 |

**O ROAS cresce monotonicamente com a idade até 55-64, onde é 2,3× a média — e essa faixa recebe 6% da verba.** Base pequena (26 clientes), então é hipótese a testar, não conclusão.

### `Meta Ads - Campanhas`
55 campanhas com investimento, conversas e custo por conversa. Nível mais granular disponível — **e ainda assim agregado**: não há como ligar uma campanha a um cliente específico.

### ⚠️ Três ressalvas obrigatórias
1. **Janela.** Verba é vitalícia (3 anos); receita atribuída cobre abr–dez/2025. O ROAS declarado de 8,59 tem o denominador inflado de propósito — **o real é maior**.
2. **Produto inferido** do nome da campanha.
3. **Conversa ≠ lead.** 6.620 conversas no Meta contra 3.385 contatos de origem Meta no CRM. **Aproximadamente metade das conversas não vira contato registrado** — é o maior vazamento medido do funil, e ninguém sabe hoje se some por falta de resposta, por desqualificação ou por falha de registro.

---

## 8. Aba `Auditoria` — o que foi herdado e reconferido

### Conferências que reproduzimos ✅

| Verificação | Declarado | Reconferido |
|---|---|---|
| Soma total de vendas | R$ 805.879,35 | ✅ R$ 805.879,35 |
| Qtd de vendas | 1.423 | ✅ 1.423 |
| Vendas 2024 / 2025 | 396 / 1.027 | ✅ |
| Cadastro / mescladas / únicos | 992 / 1 / 991 | ✅ |
| Contatos no export Kommo | 6.374 | ✅ |
| Clientes com match no CRM | 805 de 991 (81,2%) | ✅ |
| Receita clientes Meta Ads | R$ 274.613,30 | ✅ |

### Limitações declaradas na origem
- Export é de contatos, não de leads — sem etapa de funil nem valor de negociação
- "Reativação" não é canal de aquisição — separado em `Tipo de Origem`
- 1.751 contatos sem origem (27% do CRM)
- 2.091 contatos criados após 25/12/2025 — fora da janela de vendas
- Nenhuma perda de colunas na consolidação das quatro fontes

### O que este mapa acrescenta

| # | Achado novo |
|---|---|
| 1 | **Separadores decimais mistos entre abas** — armadilha que infla a receita em 2,26× se não tratada (§1) |
| 2 | **37,2% das linhas de venda são de valor zero** — "1.423 vendas" e "683 compradores" superestimam o volume comercial; os números reais são 893 e 511 (§5) |
| 3 | **`Responsável` é constante** em 100% das linhas — inutilizável para análise de desempenho (§3) |
| 4 | **72 itens com nomenclatura suja** — exige de-para canônico antes de qualquer análise por produto (§5) |
| 5 | **Divergência de grão entre `Canais de Aquisição` e `Clientes Unificados`** — 245 vs 174 compradores Meta; não misturar (§6) |
| 6 | **`Receita do Cliente` da aba `Contatos CRM` tem dupla contagem** — R$ 767.056,05 não é receita (§4) |
| 7 | **Concentração de receita**: top 100 clientes = 45,4% do faturamento (§2) |

Nenhuma verificação da `Auditoria` foi contestada.
