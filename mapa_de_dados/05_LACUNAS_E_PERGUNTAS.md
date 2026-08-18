# 05 — O que dá e o que não dá para responder

Este é o documento que transforma o mapa em ferramenta de decisão. Duas listas: o que já é respondível com os dados atuais, e o que falta — priorizado.

---

## 1. Catálogo de perguntas respondíveis

Níveis de confiança:
**🟢 Alto** — cálculo direto sobre dado conferido
**🟡 Médio** — exige junção ou tem cobertura parcial; a resposta é direcional
**🔴 Inferência** — a resposta é hipótese, não medição; serve para levantar tese, não para decidir sozinha

### 1.1 Padrões de compra por produto

| # | Pergunta | Fonte | Junção | Confiança |
|---|---|---|---|---|
| 1 | Quanto cada procedimento faturou e em quantos atendimentos? | `Vendas Detalhadas` | — | 🟢 |
| 2 | Qual o ticket típico e a dispersão por procedimento? | `Vendas Detalhadas` | — | 🟢 |
| 3 | Quais procedimentos aparecem juntos na mesma linha (venda casada)? | `Vendas Detalhadas` col. `Itens` | — | 🟢 |
| 4 | Qual a sequência típica de procedimentos ao longo da vida do cliente? | `Clientes Unificados` bloco D (listas alinhadas) | — | 🟢 |
| 5 | Quanto tempo passa entre uma compra e a seguinte, por produto? | `Clientes Unificados` bloco D | — | 🟢 |
| 6 | Qual produto é porta de entrada e qual é de expansão? | `Procedimento Inicial` (CRM) × `Itens` (Vendas) | CRM ↔ Vendas | 🟡 |
| 7 | A avaliação gratuita de Criolipólise vira procedimento pago? | `Vendas Detalhadas` (sequência por cliente) | — | 🟡 *(só quem voltou; quem não voltou não deixa registro)* |
| 8 | Qual o ROAS por produto? | abas Meta Ads | — | 🔴 *(produto inferido do nome da campanha; verba vitalícia vs. receita de 9 meses)* |

⚠️ **Todas as perguntas por produto exigem antes um de-para canônico dos 72 itens** — hoje `CRIO TURBO`, `Criolipólise 2h`, `CRIO FULL 360º`, `CRIOLIPÓLISE AVANÇADA` e `CRIO DINAMIC FLACIDEZ` são strings distintas para a mesma família. **Este é o primeiro trabalho a fazer** antes de qualquer estudo de produto.

### 1.2 Padrões de compra por cliente

| # | Pergunta | Fonte | Confiança |
|---|---|---|---|
| 9 | Qual a distribuição de recompra? | `Clientes Unificados` | 🟢 *(já medido: 308 com zero · 357 com uma · 236 com 2–3 · 90 com 4+)* |
| 10 | Quanto da receita vem dos maiores clientes? | `Clientes Unificados` | 🟢 *(top 100 = 45,4%)* |
| 11 | Qual o LTV por canal de origem? | `Clientes Unificados` | 🟢 |
| 12 | Qual o LTV por faixa etária? | `Clientes Unificados` (idade em 88%) | 🟢 |
| 13 | Coorte por mês de entrada: quem entrou quando compra quanto? | `Criado em` (CRM) × `Vendas` | 🟡 *(só coortes até 12/2025)* |
| 14 | Clientes de reativação valem mais ou menos que os novos? | `Tipo de Origem` × `Vendas` | 🟡 *(⚠️ ver alerta sobre o rótulo REATIVAÇÕES, doc 04 §6.2)* |
| 15 | Quem são os 357 clientes de compra única e o que eles compraram? | `Clientes Unificados` | 🟢 |
| 16 | Existe padrão geográfico de valor? | `Cidade CRM` (55% de cobertura) | 🟡 |
| 17 | Quanto tempo passa entre entrar no CRM e a primeira compra? | `Criado em` × `Primeira Compra` | 🟢 *(nos 805 com match)* |

### 1.3 Canal, mídia e aquisição

| # | Pergunta | Fonte | Confiança |
|---|---|---|---|
| 18 | Qual canal converte melhor contato→comprador? | `Canais de Aquisição` | 🟢 *(Indicação 77,8% · Instagram 51,6% · Meta 12,0%)* |
| 19 | Qual o CAC máximo suportável por canal? | `Canais de Aquisição` | 🟢 |
| 20 | Qual faixa etária dá o melhor retorno no Meta Ads? | `Meta Ads - Faixa Etária` | 🟡 *(55-64 com ROAS 18,05, mas base de 26 clientes)* |
| 21 | Qual campanha custa mais por conversa? | `Meta Ads - Campanhas` | 🟢 |
| 22 | **Qual campanha trouxe qual cliente?** | — | ⛔ **impossível** |
| 23 | Quantas conversas do Meta viram contato no CRM? | Meta Ads × CRM | 🟡 *(6.620 conversas vs. 3.385 contatos ≈ 51% — agregado, não rastreável)* |
| 24 | Vale realocar verba de Criolipólise para Endolaser? | `Meta Ads - Produto` | 🔴 *(ROAS 7,01 vs 13,32 é forte, mas produto é inferido)* |

### 1.4 Relacionamento e conversa (WhatsApp)

⚠️ Tudo nesta seção é **caracterização, não medição** — a amostra é 0,55% da base e enviesada para conversas longas. Nenhum percentual daqui deve ser extrapolado.

| # | Pergunta | Fonte | Confiança |
|---|---|---|---|
| 25 | Em que horários e dias os clientes falam? | corpus WhatsApp | 🟡 *(81,5% entre 8h–17h; quarta é o pico; fim de semana é 8%)* |
| 26 | Quanto a clínica demora para responder? | corpus WhatsApp | 🟡 *(mediana 9,6 min, p90 11,7h)* |
| 27 | Quem inicia e quem encerra a conversa? | corpus WhatsApp | 🟡 *(cliente inicia 33/35; clínica fala por último 26/35)* |
| 28 | Qual o script de qualificação em uso? | corpus WhatsApp | 🟢 *(documentado no doc 03 §4.4)* |
| 29 | Quais objeções aparecem? | corpus WhatsApp | 🔴 *(só as escritas — as discutidas em áudio estão perdidas)* |
| 30 | Como o preço é apresentado? | — | ⛔ **impossível — está nos 287 áudios ocultos** |
| 31 | Quantos toques até agendar? | corpus WhatsApp | 🔴 *(sem dado de agendamento para confirmar o desfecho)* |
| 32 | Resposta lenta reduz conversão? | corpus × Vendas | 🔴 *(a tese é forte e testável, mas n=29 conversas com match)* |
| 33 | Qual o intervalo do ciclo de reativação? | corpus WhatsApp | 🟡 *(caso observado: 5 meses entre tentativa e retomada)* |

### 1.5 Perguntas de qualidade de dados

| # | Pergunta | Confiança |
|---|---|---|
| 34 | Qual % dos contatos tem origem identificada? | 🟢 *(72,5%)* |
| 35 | Qual % dos clientes tem vínculo com o CRM? | 🟢 *(81,2%; 96% dos novos de abr–dez/25)* |
| 36 | Quantos contatos estão fora da janela de vendas? | 🟢 *(2.091)* |
| 37 | Quantos atendimentos são gratuitos? | 🟢 *(530 de 1.423 = 37,2%)* |
| 38 | Os contatos de "reativação" são mesmo ex-clientes? | 🟢 *(**não** — só 22,5% existem no cadastro)* |

---

## 2. Matriz de lacunas — priorizada

| # | Lacuna | Impacto na decisão | Onde deveria ser capturada | Esforço | Prioridade |
|---|---|---|---|---|---|
| **1** | **Etapa de funil e histórico de movimentação** — o export é de contatos, não de leads | **Bloqueia diretamente o objetivo do projeto.** Sem etapa, sem tempo em etapa e sem motivo de perda, não há o que reestruturar — só se sabe o desfecho, nunca onde travou | Kommo, entidade *lead* | **Trivial** — é reexportar com o objeto certo | 🔥 **1** |
| **2** | **Agendamento, comparecimento, no-show, cancelamento** | Não se separa "não vendeu" de "vendeu e não apareceu". A `AVALIAÇÃO CRIO` gratuita é 23% de todos os atendimentos e ninguém sabe quantas viram procedimento pago — é a conversão mais importante da clínica e é invisível | Sistema de agendamento | Médio — **depende dos dados novos** | 🔥 **2** |
| **3** | **Atribuição por campanha no nível do lead** (`click_id`/UTM) | R$ 31.981,35 em 55 campanhas decididos no agregado. O sinal de que Endolaser rende 2× a Criolipólise não é confirmável nem acionável com segurança | Kommo, no momento da criação do contato, vindo do Meta | **Baixo** — configuração, não desenvolvimento | 🔥 **3** |
| **4** | **Metade das conversas do Meta não vira contato** (6.620 vs 3.385) | O maior vazamento medido do funil. Não se sabe se some por falta de resposta, desqualificação ou falha da automação | Automação Meta → Kommo | Baixo — investigação | **4** |
| **5** | **Janela de vendas fecha em 25/12/2025** | 2.091 contatos (33% do CRM) inatribuíveis. 4 dos 10 clientes do teste de junção travaram exatamente aqui | Sistema de agendamento | — | **Em resolução** ✅ |
| **6** | **Conteúdo de áudio e imagem do WhatsApp** — 287 áudios, 234 imagens | A venda acontece no áudio. Toda leitura sobre argumentação e preço tirada do texto é sistematicamente errada, não só incompleta | Export do WhatsApp com mídia — **já comprovadamente possível** (doc 03 §6) | Baixo para reexportar; médio para transcrever | **6** |
| **7** | **Amostra de conversas: 35 de 6.374 (0,55%)**, enviesada para conversas longas | Impede qualquer medição de taxa sobre comportamento de conversa | Export estratificado (§3) ou export do CRM | Médio | **7** |
| **8** | **27,5% dos contatos sem origem** (1.751) | Um quarto do topo do funil é cego. E o bloco "sem origem" tem o **maior LTV de todos** (R$ 1.720,48) — literalmente não se sabe de onde vem o cliente mais valioso | Campo obrigatório no cadastro do Kommo | **Trivial** | **8** |
| **9** | **CPF em 7,6% dos contatos** | A chave de match mais forte é a mais rara. Com CPF universal a junção iria de 81,2% a ~100% | Cadastro no Kommo | Baixo | **9** |
| **10** | **Nomenclatura suja: 72 itens sem padrão** | Impede qualquer análise por produto sem trabalho prévio de canonização | Cadastro de procedimentos no sistema | Baixo — de-para manual | **10** |
| **11** | **Pós-venda e sucesso do cliente: nenhum registro** | 357 clientes de compra única e nada que explique por quê. Sem satisfação, resultado clínico ou retorno programado, retenção é chute | Processo novo | Alto — processo, não sistema | **11** |
| **12** | **Atendente real não é registrado** em nenhuma das três fontes | Nenhuma análise de desempenho por pessoa é possível. `Responsável` é constante em 100% das vendas; o CRM é quase monocolor; no WhatsApp o atendente só assina no texto livre | Campo estruturado no CRM | Baixo | **12** |
| **13** | **Campos `Nota 1..5` vazios em 6.378 linhas** | Todo o contexto qualitativo do lead — objeção, condição de saúde, expectativa — não existe de forma estruturada | Kommo | Trivial | **13** |
| **14** | **`Termos do usuário` = `Não` em 99,9%** | Risco de LGPD sobre 6.374 pessoas em base ativa de comunicação | Kommo | Trivial | **14** |
| **15** | **Rótulo `REATIVAÇÕES` não corresponde ao que nomeia** | 77,5% dos "reativados" nunca foram clientes. `Tipo de Origem = Trabalho sobre a base` induz leitura errada de R$ 141.805,40 de receita e do CAC do canal | Definição operacional, não sistema | **Trivial** — é uma conversa | 🔥 **Verificar antes de qualquer decisão** |

### Onde concentrar esforço

As lacunas **1, 3, 8 e 15** custam quase nada — são reexportar com o objeto certo, ligar um campo, tornar um campo obrigatório e esclarecer uma definição. Juntas, elas destravam o funil, a decisão de verba e a leitura de canal. **É o melhor retorno disponível.**

A lacuna **2** é a mais valiosa e depende dos dados novos.
A lacuna **11** é a única que exige criar processo do zero.

---

## 3. Ponto de entrada dos dados do novo sistema de agendamento

Para que os dados novos se encaixem sem retrabalho, precisam vir com este grão e estas chaves:

### 3.1 Agendamentos — a tabela que hoje não existe

Um registro **por agendamento**, não por atendimento realizado:

| Campo | Por que é necessário |
|---|---|
| `id_agendamento` | Chave própria |
| `telefone` | **Chave de junção obrigatória** — normalizado, permitindo os 8 últimos dígitos |
| `cpf` | Chave forte quando disponível |
| `nome` | Apoio |
| `data_hora_agendada` | Análise de horário e antecedência |
| `data_hora_marcacao` | **Quando foi marcado** — permite medir antecedência e o intervalo lead→agendamento |
| `procedimento_agendado` | Casar com `Procedimento Inicial` do CRM |
| **`status`** | `agendado` · `compareceu` · `no-show` · `cancelado_cliente` · `cancelado_clinica` · `remarcado`. **É o campo mais importante de todo o pedido** |
| `motivo_cancelamento` | Se existir |
| `id_agendamento_origem` | Em remarcações, apontando para o anterior — permite reconstruir a cadeia |
| `profissional` | Resolve a lacuna 12 |
| `unidade` | Se houver mais de uma |

### 3.2 Atendimentos realizados — estender o que já temos

Mesmo formato de `Vendas Detalhadas`, com quatro adições:

- `id_agendamento` → **liga o realizado ao agendado**, fechando o elo que falta
- `procedimento` **canônico** (com um código, não texto livre) → resolve a lacuna 10
- `sessao_n` de `total_sessoes` em pacotes → distingue venda de execução
- Separação explícita entre **avaliação gratuita** e **procedimento pago** → resolve a ambiguidade das 530 linhas de valor zero

### 3.3 Financeiro, se disponível

Forma de pagamento, parcelamento, desconto aplicado e valor de tabela versus valor praticado. O corpus de WhatsApp mostra `cartão` (20), `parcel` (9) e `pix` (7) — a negociação de pagamento existe e hoje não é medida em lugar nenhum.

### 3.4 Janela
**A partir de 25/12/2025**, para emendar sem sobreposição. Se vier a série histórica completa, melhor — permite reconciliar e validar a consolidação anterior.

### 3.5 O que revisar quando os dados chegarem
- `00_VISAO_GERAL.md` §1 e §2 — a etapa 4 deixa de ser cega
- `02_DICIONARIO_BASE_UNIFICADA.md` — nova seção para as tabelas novas
- Este documento, §1 — várias perguntas 🔴 e ⛔ passam a 🟢
- A lacuna 5 sai da matriz

---

## 4. Sequência recomendada de trabalho

Com o mapa pronto, a ordem que maximiza retorno:

1. **Esclarecer o rótulo `REATIVAÇÕES`** com a operação. É uma conversa de 10 minutos que muda a leitura de um canal inteiro e de R$ 141.805,40 de receita.
2. **Pedir o export de *leads* do Kommo.** Destrava o objetivo central do projeto e não custa nada.
3. **Construir o de-para canônico dos 72 procedimentos.** Pré-requisito de toda análise de produto.
4. **Ligar `click_id`/UTM no Kommo.** Não recupera o passado, mas para de perder o futuro — quanto antes, mais cedo o histórico começa.
5. **Tornar `Origem` obrigatória no cadastro.** Fecha o ponto cego de 27,5%.
6. **Reexportar o WhatsApp com mídia**, amostra estratificada de ~200 conversas (doc 03 §7) — verificando antes se o próprio Kommo exporta o histórico.
7. **Quando os dados novos chegarem**, refazer a coorte completa e revisar este mapa.

Só depois disso a análise de fato — reestruturação de funil, coortes, remapeamento de clientes — se apoia em chão firme.
