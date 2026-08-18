# 00 — Arquitetura Comercial: a visão geral

> Documento-raiz do desenho de processos comerciais, operacionais e de relacionamento da clínica.
> Leia este primeiro. Os demais aprofundam cada camada.
> Versão 1 — construída sobre o [`mapa_de_dados/`](../mapa_de_dados/00_VISAO_GERAL.md) e sobre as análises em [`_analises/RESULTADOS.md`](_analises/RESULTADOS.md).

---

## 1. O problema, em uma frase

A clínica **vende bem e não sabe como**. R$ 805.879,35 em 17 meses, ROAS agregado acima de 8, e ao mesmo tempo: metade das conversas do Meta some antes de virar registro, ninguém sabe quantas avaliações gratuitas viram procedimento pago, não existe um único dado de agendamento, e 64% dos clientes pagantes compraram uma vez só e nunca mais voltaram.

Não falta esforço comercial. Falta **um processo que produza o dado enquanto opera** — hoje o dado é reconstruído meses depois, cruzando planilhas, e por isso nunca chega a tempo de mudar uma decisão.

---

## 2. O desenho em uma imagem

```
  ANÚNCIO          CONVERSA           AVALIAÇÃO          PROCEDIMENTO        RELACIONAMENTO
     │                 │                   │                   │                   │
     ▼                 ▼                   ▼                   ▼                   ▼
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Meta    │────▶│  FUNIL 1    │────▶│  FUNIL 2    │────▶│  FUNIL 3    │────▶│  FUNIL 4    │
│ Ads     │     │  AQUISIÇÃO  │     │  CONVERSÃO  │     │  ENTREGA    │     │ RELACIONA-  │
│         │     │             │     │             │     │             │     │  MENTO      │
└─────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
 ctwa_clid       lead→agenda        compareceu→vendeu    protocolo→resultado   segmento→oferta
     │                 │                   │                   │                   │
     └─────────────────┴───────────────────┴───────────────────┴───────────────────┘
                                           │
                              5 chaves amarram tudo:
                    telefone(8) · cpf · ctwa_clid · id_agendamento · cod_procedimento
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │   PAINEL    │  15 indicadores
                                    └─────────────┘
```

**O ciclo se fecha:** o Funil 4 devolve gente para o Funil 2 (recompra) e para o Funil 1 (indicação) — sem passar por mídia paga. É onde está a margem.

**Onde tudo isso é gravado.** Kommo e Meta são **fontes de entrada**, não onde os dados moram. Todo toque de toda pessoa vira um evento imutável num banco próprio — o **lastro** — de onde saem funil, segmento, régua e painel. O modelo está em [`06_MODELO_DE_DADOS.md`](06_MODELO_DE_DADOS.md): 14 tabelas, 34 tipos de evento, e uma tabela de **expectativas** que registra o que deveria ter acontecido e não aconteceu — porque abandono, em estética, é sempre a ausência de um evento esperado.

---

## 3. Os quatro funis, e por que exatamente quatro

| Funil | Cuida de | Dono | Métrica-mãe | Hoje |
|---|---|---|---|---|
| **1 — Aquisição** | Lead até a avaliação agendada | Atendimento/SDR | % de conversa que vira avaliação agendada | Existe informalmente, não é medido |
| **2 — Conversão** | Avaliação até a venda | Avaliadora/vendedora | % de avaliação realizada → procedimento pago | **Cego** |
| **3 — Entrega** | Protocolo em execução até o resultado | Operacional/clínico | % de protocolo concluído | **Não existe** |
| **4 — Relacionamento** | A base inteira, segmentada | Relacionamento | % da base que recompra dentro do ciclo | **Não existe** |

**Por que não um funil só:** lead e cliente têm ritmos, donos e métricas incompatíveis. Um lead do Meta compra em **6 dias na mediana** (A5); um cliente de injetáveis faciais volta em **164 dias** (A3). No mesmo pipeline, o segundo parece um lead morto — e é justamente o cliente mais valioso da casa.

**Por que não seis ou oito:** cada funil a mais é uma fronteira a mais para o card atravessar, e fronteira sem dono é onde o card para. Quatro é o mínimo que separa os quatro ritmos reais da operação.

---

## 4. Os três handoffs — onde processos morrem

Card parado em fronteira é o modo de falha mais comum de qualquer operação comercial. Cada passagem tem regra explícita:

| Handoff | Gatilho automático | Quem assume | Prazo |
|---|---|---|---|
| **F1 → F2** | Agendamento criado no sistema de agenda | Avaliadora | Imediato |
| **F2 → F3** | Venda registrada com protocolo e nº de sessões | Operacional | Mesmo dia |
| **F3 → F4** | `resultado_registrado` (ou protocolo abandonado) | Relacionamento | 48h |
| **F4 → F2** | Cliente responde a uma régua com intenção | Vendedora | Imediato |

**Regra dura:** nenhum handoff é manual. Se depende de alguém lembrar de mover o card, ele não acontece — e o dado que nasceria ali some. É exatamente o que produziu os dois pontos cegos atuais.

---

## 5. Os cinco princípios que sustentam o desenho

**1. Etapa que ninguém move é lixo.** Cada etapa tem critério de saída objetivo, verificável por terceiro, e um dado que nasce dela. Etapa que não passa nesse teste foi cortada.

**2. O dado nasce do trabalho, não de digitação extra.** Nenhum campo obrigatório proposto exige trabalho que a operação já não faça. O `Origem` obrigatório é um clique; a etapa `Compareceu` é o check-in que já acontece na recepção.

**3. A avaliação gratuita é o produto de entrada, não um custo.** São 504 linhas de avaliação, 23% de toda a agenda da clínica. Agora sabemos que **30,4% dos que fazem avaliação acabam pagando algum procedimento** (A6) — e esse número é o piso, porque quem agendou e não apareceu não existe em fonte nenhuma. É a métrica-mãe da operação.

**4. Recência absoluta não significa nada em estética.** 60 dias sem voltar é normal para criolipólise (ciclo p75 de 70 dias) e é atraso grave para endolaser (33 dias). Por isso o modelo de segmentação usa **recência relativa ao ciclo do procedimento** — ver [`03_SEGMENTACAO_E_REGUAS.md`](03_SEGMENTACAO_E_REGUAS.md).

**5. O canal que mais converte é o que menos se alimenta.** Indicação converte **77,8%** contra 12,0% do Meta Ads, e responde por 0,6% do topo do funil. Um pedido de indicação estruturado dentro do Funil 3 é provavelmente a maior alavanca isolada de aquisição da clínica — e custa zero de mídia.

---

## 6. O que muda, em números

| Hoje | Depois |
|---|---|
| Metade das conversas do Meta some sem virar registro | Toda conversa vira lead com `ctwa_clid`; a perda passa a ter nome e etapa |
| Não se sabe qual campanha trouxe qual cliente | ROAS por campanha no nível da pessoa |
| Avaliação → venda: **invisível** | Métrica-mãe medida semanalmente |
| "Não vendeu" e "não apareceu" são a mesma coisa | No-show separado, com causa |
| 27,5% dos contatos sem origem — e é o grupo de maior LTV | Campo obrigatório: 0% sem origem |
| Reativação disparada para lista fria rotulada como base | Réguas por segmento, no ciclo de cada procedimento |
| 64,2% dos pagantes compram uma vez e somem | Régua de recompra dispara no p75 do ciclo, antes do cliente esfriar |
| Desempenho por atendente: impossível em 3 fontes | Campo estruturado de atendente em cada etapa |

---

## 7. Índice

| Documento | O que contém |
|---|---|
| [`01_FUNIS_E_ETAPAS.md`](01_FUNIS_E_ETAPAS.md) | Os quatro funis etapa a etapa: critério de entrada e saída, SLA, dono, campos obrigatórios, motivos de perda |
| [`02_TRACKING.md`](02_TRACKING.md) | O dicionário de eventos do anúncio à nota fiscal, as 5 chaves de amarração, e as 4 configurações de custo zero |
| [`03_SEGMENTACAO_E_REGUAS.md`](03_SEGMENTACAO_E_REGUAS.md) | Por que não é RFM, o modelo Estágio × Valor × Recência Relativa com cortes calibrados, e a régua de cada segmento |
| [`04_PAINEL_KPI.md`](04_PAINEL_KPI.md) | Os 15 indicadores: fórmula, fonte, linha de base medida e meta |
| [`05_IMPLANTACAO.md`](05_IMPLANTACAO.md) | As quatro ondas, o que é configuração no Kommo hoje, e o gatilho de migração de stack |
| [`06_MODELO_DE_DADOS.md`](06_MODELO_DE_DADOS.md) | **O lastro**: 14 tabelas, 34 tipos de evento, 6 namespaces de tag, e como eventos cíclicos viram fila de trabalho |
| [`_analises/RESULTADOS.md`](_analises/RESULTADOS.md) | A saída de A1–A7 que calibra tudo acima |
| [`_analises/analises.ps1`](_analises/analises.ps1) | O script que a produz, com guarda de conferência |

---

## 8. O que este desenho **não** resolve

Honestidade sobre limites, no mesmo espírito do `mapa_de_dados`:

- **Não recupera o passado.** `ctwa_clid` começa a valer no dia em que for ligado. Os 55 campanhas já rodadas seguem sem atribuição por pessoa.
- **Não substitui a conversa.** 287 áudios perdidos continuam perdidos; a venda desta clínica acontece falando, e nenhum campo de CRM captura isso.
- **Depende do novo sistema de agendamento** para os Funis 2 e 3 funcionarem de verdade. Sem status de comparecimento, o Funil 2 opera às cegas na etapa que mais importa.
- **Não é um projeto de tecnologia.** A parte cara é a disciplina de operação — mover card, preencher campo, seguir régua. Nenhuma automação compensa a ausência disso.
