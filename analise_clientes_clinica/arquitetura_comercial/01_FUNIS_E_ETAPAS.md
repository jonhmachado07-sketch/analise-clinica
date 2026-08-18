# 01 — Os quatro funis, etapa a etapa

Cada etapa tem quatro coisas obrigatórias: **critério de saída** verificável, **SLA**, **dono**, e **o dado que nasce ali**. Etapa sem as quatro foi cortada do desenho.

---

## Funil 1 — AQUISIÇÃO

**Do primeiro contato até a avaliação agendada.**
Dono: atendimento/SDR · Métrica-mãe: **% de conversa que vira avaliação agendada**

| # | Etapa | Critério de saída | SLA | Dado que nasce |
|---|---|---|---|---|
| 1 | **Novo** | Contato criado automaticamente com `origem`, `ctwa_clid` e `produto_anunciado` | — | Atribuição de campanha |
| 2 | **Em contato** | Primeira resposta humana enviada | **≤ 10 min** (8h–18h) · ≤ 1h fora | Tempo de 1ª resposta + atendente |
| 3 | **Qualificado** | Motivação, histórico e região preenchidos | 24h | Perfil de interesse estruturado |
| 4 | **Avaliação agendada** | `id_agendamento` existe | 48h | Elo lead↔agenda |
| 5 | **✅ Ganho** → Funil 2 · **❌ Perdido** | Motivo de perda selecionado | — | Causa de perda |

### O SLA de 10 minutos não é arbitrário

A mediana atual de primeira resposta é **9,6 minutos** — ou seja, metade da operação já cumpre. O problema é a cauda: o **p90 é 11,7 horas**, o que na prática significa "só no dia seguinte" (`mapa_de_dados/03` §4.3). E o cliente responde **3× mais rápido** que a clínica.

O SLA existe para matar a cauda, não para melhorar a mediana. **O indicador a acompanhar é o p90, não a média.**

### Motivos de perda — lista fechada, sem campo livre

`sem resposta (3 tentativas)` · `preço` · `distância / logística` · `contraindicação clínica` · `só pesquisando` · `já fez em outro lugar` · `número inválido / duplicado` · `fora da área de atendimento`

Campo livre não agrega: os `Nota 1..5` do Kommo estão vazios em **6.378 linhas de 6.378**. Lista fechada de 8 opções é preenchível em um clique e agregável no fim do mês.

### Quando o lead morre

Medido em A5: dos clientes que compraram, **57% compraram em até 7 dias** e **84% em até 30 dias**; o p90 é 58 dias.

| Regra | Prazo |
|---|---|
| Cadência ativa de contato | 3 tentativas em 7 dias |
| Segunda cadência (leve) | dias 15 e 30 |
| **Perde por `sem resposta`** | **60 dias** (arredondando o p90) |
| Destino | Segmento `Lead frio` no Funil 4, nunca deletado |

⚠️ Isto é medido **sobre quem comprou** — é a janela em que a compra acontece, não a prova de que ninguém compra depois. Revisar quando houver dados de 2026.

---

## Funil 2 — CONVERSÃO

**Da avaliação agendada até a venda.**
Dono: avaliadora/vendedora · Métrica-mãe: **% de avaliação realizada → procedimento pago**

| # | Etapa | Critério de saída | SLA | Dado que nasce |
|---|---|---|---|---|
| 1 | **Avaliação agendada** | — | — | Antecedência da marcação |
| 2 | **Confirmada** | Confirmação ativa do cliente | D-1 e D-0 | Sinal precoce de no-show |
| 3 | **Compareceu** | Check-in na recepção | — | **No-show separado de "não vendeu"** |
| 4 | **Proposta apresentada** | Valor e protocolo no card | mesma visita | Valor de tabela vs. praticado |
| 5 | **✅ Vendido** · **🔁 Em negociação** · **❌ Perdido** | Motivo | 72h para sair de "em negociação" | Taxa de fechamento |

### A métrica-mãe, medida pela primeira vez

Cruzando avaliação gratuita com compra posterior no mesmo cliente (A6):

| Indicador | Valor |
|---|---:|
| Clientes com avaliação gratuita registrada | 395 |
| Destes, pagaram algum procedimento depois | 120 |
| **Conversão avaliação → pago** | **30,4%** |

⚠️ **Este é o piso, não a taxa real.** Só enxerga quem compareceu e teve atendimento registrado. Quem agendou e não apareceu não existe em fonte nenhuma. A etapa 3 deste funil é o que transforma esse piso em medição.

E o outro lado do mesmo número: **172 pessoas foram atendidas e geraram R$ 0**. Destas, **168 vieram uma única vez** — 147 fizeram `AVALIAÇÃO CRIO`. São pessoas que já estiveram fisicamente dentro da clínica e nunca mais voltaram, sem processo nenhum apontado para elas.

### Motivos de perda do Funil 2

`preço / não cabe no orçamento` · `vai pensar` · `contraindicação identificada na avaliação` · `expectativa incompatível com o procedimento` · `foi fazer em outro lugar` · `sumiu após a avaliação`

⚠️ `vai pensar` merece contagem separada: no corpus de WhatsApp, o abandono típico não é um "não" — é silêncio depois de uma mensagem da clínica (a clínica fala por último em **26 das 35 conversas**). Se `vai pensar` for o motivo majoritário, o problema é de fechamento, não de preço.

### Roteiro de proposta — sustentado pelos dados

**38,4% das linhas pagas têm mais de um item** (A7): a venda casada é o padrão, não a exceção. As combinações reais:

| Combinação | Ocorrências |
|---|---:|
| Criolipólise + protocolo pré/pós | 138 |
| Endolaser + Morosil | 82 |
| Endolaser + protocolo pós | 82 |
| Protocolo pós endolaser + Morosil | 77 |
| Criolipólise + Morosil | 49 |

**A Cápsula Morosil é o maior item de receita da clínica** (R$ 240.049,90), não tem campanha nenhuma no Meta Ads e **zero menções** em todo o corpus de WhatsApp. É venda de balcão, feita na conversa presencial. Deve virar item explícito do roteiro de proposta — hoje depende de quem está atendendo lembrar.

---

## Funil 3 — ENTREGA

**Do protocolo iniciado ao resultado registrado.**
Dono: operacional/clínico · Métrica-mãe: **% de protocolo concluído**

| # | Etapa | Critério de saída | Dado que nasce |
|---|---|---|---|
| 1 | **Protocolo iniciado** | 1ª sessão realizada | `sessao_n` / `total_sessoes` |
| 2 | **Em execução** | Cada sessão com check-in | Aderência, intervalo entre sessões |
| 3 | **Protocolo concluído** | Última sessão realizada | Taxa de conclusão |
| 4 | **Resultado registrado** | Foto/medida + NPS | **Satisfação e resultado clínico** |
| 5 | **Indicação solicitada** | Pedido feito e registrado | Origem `Indicação` alimentada |
| → | Sai para o Funil 4 | — | — |

### Por que este funil existe

Ele não vende nada. Ele produz **os três dados que hoje não existem em fonte nenhuma**: sessão *n* de *N*, resultado clínico e satisfação. Sem eles, retenção é chute — e o `mapa_de_dados/05` classifica isso como a única lacuna que exige criar processo do zero.

### A etapa 5 é a de maior retorno do desenho inteiro

| Canal | Contatos | Conversão | Receita |
|---|---:|---:|---:|
| Meta Ads | 2.043 | 11,99% | R$ 271.605,40 |
| **Indicação** | **36** | **77,78%** | R$ 43.167,90 |

Indicação converte **6,5× melhor** que Meta Ads e é 0,6% do topo do funil. Trinta e seis contatos em toda a história da clínica — porque ninguém pede. Pedir no momento certo (logo após `resultado_registrado`, com o resultado na mão) é uma etapa de trinta segundos que alimenta o melhor canal da casa.

⚠️ Cuidado real: a base é pequena (36 contatos) e enviesada — indicação chega pré-vendida. A conversão cairá conforme o volume subir. Ainda assim, qualquer número acima de 30% já domina o Meta Ads.

---

## Funil 4 — RELACIONAMENTO

**A base inteira, segmentada.**
Dono: relacionamento · Métrica-mãe: **% da base que recompra dentro do ciclo**

Não é um pipeline de arrastar card. É um **motor de segmentos** (detalhado em [`03_SEGMENTACAO_E_REGUAS.md`](03_SEGMENTACAO_E_REGUAS.md)) que reclassifica a base todo dia e dispara réguas. O card só entra em pipeline quando o cliente responde com intenção — e aí volta direto para a etapa 4 do Funil 2.

| Estado | Definição | O que acontece |
|---|---|---|
| **No ciclo** | Recência relativa < 1,0 | Nada. Não incomodar. |
| **Atrasado** | 1,0 – 2,0 | Régua de recompra do procedimento |
| **Dormindo** | 2,0 – 3,0 | Régua de reativação com oferta |
| **Frio** | > 3,0 | Campanha ampla, baixa frequência |
| **Avaliou e não comprou** | Atendimento com R$ 0, sem compra posterior | Régua própria — o público mais barato da base |

### ⚠️ Antes de ligar este funil: resolver o rótulo `REATIVAÇÕES`

**77,5% dos 1.104 contatos marcados como "reativação" nunca foram clientes da clínica** (`mapa_de_dados/04` §6.2). E A5 confirma pelo comportamento: quem entra por esse rótulo e compra leva **48 dias na mediana** contra 6 dias do Meta Ads, e **0% compra em até 7 dias**. Isso não é comportamento de ex-cliente sendo reativado — é comportamento de lead frio.

Consequência: R$ 141.805,40 estão creditados a um "trabalho sobre a base" que, na maior parte, é aquisição fria disfarçada — e o CAC do canal está sendo lido errado.

**É uma conversa de dez minutos com a operação e precede o desenho deste funil.**

---

## Resumo: 19 etapas, 4 donos, 1 regra

| Funil | Etapas | Dono | Métrica-mãe | Linha de base hoje |
|---|---:|---|---|---|
| 1 — Aquisição | 5 | Atendimento | conversa → avaliação agendada | não medido |
| 2 — Conversão | 5 | Vendedora | avaliação → pago | **30,4%** (piso) |
| 3 — Entrega | 5 | Operacional | protocolo concluído | não existe |
| 4 — Relacionamento | 4 estados | Relacionamento | recompra no ciclo | **35,8%** dos pagantes |

**A regra:** todo handoff é automático (`00_ARQUITETURA.md` §4). Card que depende de alguém lembrar de mover não se move — e é exatamente assim que os dois pontos cegos atuais foram criados.
