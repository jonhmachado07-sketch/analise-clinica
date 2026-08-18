# 04 — Painel: os 15 indicadores

Quinze. Não trinta. Indicador que ninguém olha toda semana não é indicador — é enfeite.

Cada linha traz fórmula exata, fonte, **linha de base medida** (quando existe) e meta inicial. Onde a linha de base diz "cego", o indicador só passa a existir depois da implantação — e essa é justamente a razão de ele estar na lista.

---

## 1. Topo — mídia e entrada

| # | Indicador | Fórmula | Fonte | Linha de base | Meta |
|---|---|---|---|---|---|
| 1 | **Conversas → contato** | contatos criados ÷ conversas iniciadas | Meta × CRM | **~51%** (6.620 → 3.385) | ≥ 90% |
| 2 | Custo por lead, por campanha | investimento ÷ leads | Meta + `ctwa_clid` | R$ 4,52/conversa (não é lead) | teto por canal (§4) |
| 3 | **% de leads com origem preenchida** | leads com `origem` ÷ total | Kommo | **72,5%** | 100% |
| 4 | Leads por família de procedimento | contagem por `produto_anunciado` | Kommo | Crio 2.836 · Endo 1.633 | equilibrar (§4) |

⚠️ O indicador 1 é o maior vazamento medido da operação: metade do topo do funil pago desaparece antes de virar registro, e ninguém sabe se é falta de resposta, desqualificação ou falha da automação.

---

## 2. Meio — atendimento e conversão

| # | Indicador | Fórmula | Fonte | Linha de base | Meta |
|---|---|---|---|---|---|
| 5 | **Tempo até 1ª resposta — p90** | p90 do intervalo 1ª msg cliente → 1ª resposta | Kommo | **11,7 h** | ≤ 30 min |
| 6 | Tempo até 1ª resposta — mediana | idem, p50 | Kommo | 9,6 min | ≤ 10 min |
| 7 | **Lead → avaliação agendada** | agendamentos ÷ leads | Kommo × Agenda | **cego** | definir após 1º mês |
| 8 | **Taxa de comparecimento** | `compareceu` ÷ agendados | Agenda | **cego** | ≥ 80% |
| 9 | **⭐ Avaliação → procedimento pago** | clientes que pagaram após avaliação ÷ clientes com avaliação | Agenda + vendas | **30,4%** (piso) | ≥ 45% |
| 10 | Tempo lead → 1ª compra (p75) | p75 dos dias entre `criado_em` e 1ª compra | CRM × vendas | **17 dias** | manter |

**O indicador 9 é a métrica-mãe da clínica.** A avaliação gratuita é 23% de toda a agenda; cada ponto percentual de conversão vale mais que qualquer otimização de anúncio. Hoje é o piso medido em cima de quem compareceu — a taxa verdadeira só aparece com o indicador 8 no ar.

**Por que o p90 vem antes da mediana:** a mediana de 9,6 min já é boa. O problema é a cauda — em 10% dos casos a resposta leva quase 12 horas, o que na prática é "só amanhã". O cliente responde 3× mais rápido que a clínica.

---

## 3. Fundo — receita

| # | Indicador | Fórmula | Fonte | Linha de base | Meta |
|---|---|---|---|---|---|
| 11 | **Ticket mediano pago** | mediana dos atendimentos com valor > 0 | Vendas | **R$ 707,90** | ≥ R$ 800 |
| 12 | **% de vendas casadas** | linhas pagas com 2+ itens ÷ linhas pagas | Vendas | **38,4%** | ≥ 50% |
| 13 | **CAC vs. teto por canal** | investimento ÷ clientes, contra o LTV do canal | Meta × vendas | teto Meta R$ 132,94/lead | CAC ≤ 50% do teto |

⚠️ **Ticket mediano, nunca média.** A distribuição é fortemente bimodal — sessões avulsas baratas (p25 R$ 150) contra pacotes (p90 R$ 2.000). A média esconde exatamente a informação que interessa.

O indicador 12 tem alavanca conhecida: a Cápsula Morosil, maior item de receita da clínica (R$ 240.049,90), sai em 82 vendas casadas com endolaser e **não é oferecida sistematicamente** — depende de quem está atendendo lembrar.

---

## 4. Base — retenção e relacionamento

| # | Indicador | Fórmula | Fonte | Linha de base | Meta |
|---|---|---|---|---|---|
| 14 | **Taxa de recompra** | clientes com 2+ compras pagas ÷ pagantes | Vendas | **35,8%** (182 de 509) | ≥ 45% |
| 15 | **Indicações geradas/mês** | contatos com `origem = Indicação` | CRM | **~2/mês** (37 no total) | ≥ 15/mês |

**Complementares, mesma família:**

| Recorte | Linha de base |
|---|---|
| % da base `no ciclo` vs. `dormindo` | a medir na 1ª execução do motor de segmentos |
| Clientes de compra única | **327 (64,2% dos pagantes)** |
| Atendidos que nunca pagaram | **172** |
| Concentração no topo | 55 clientes = **31,4%** da receita |

O indicador 15 é o de maior retorno por esforço do painel inteiro: indicação converte **77,8%** contra 12,0% do Meta Ads e responde por 0,6% do topo do funil — porque ninguém pede.

---

## 5. Ritmo de leitura

| Frequência | O que se olha | Quem |
|---|---|---|
| **Diário** | 5, 8 — SLA e no-show do dia | Atendimento |
| **Semanal** | 1, 7, 9, 11, 12 — o funil da semana | Comercial + gestão |
| **Mensal** | 2, 3, 13, 14, 15 — canal, CAC, base | Gestão |
| **Trimestral** | Recalibração dos ciclos e cortes de segmento | Gestão + análise |

**Regra de reunião:** a semanal olha cinco números e escolhe **uma** ação. Painel que produz discussão sem decisão vira relatório, e relatório ninguém lê no segundo mês.

---

## 6. Três armadilhas de leitura

**1. Não somar o que não soma.** As colunas de contatos de `Canais de Aquisição` somam mais que o total (56 clientes aparecem em mais de um canal). `Receita do Cliente` de `Contatos CRM` tem dupla contagem — R$ 767.056,05 não é receita de ninguém. E receita por família (`02_TRACKING.md` §2) serve para ranquear, nunca para somar.

**2. Não misturar grão.** Contato ≠ cliente. Meta Ads tem 245 compradores no grão de contato e 174 clientes pagantes no grão de cliente. Os dois números estão certos; usá-los na mesma conta, não.

**3. Não comparar janelas diferentes.** A verba de mídia é vitalícia (3 anos); a receita atribuída cobre 9 meses. O ROAS de 8,59 tem o denominador inflado de propósito — o real é maior. Qualquer ROAS calculado sem alinhar janela está errado.

---

## 7. Onde o painel mora

Onda 4 da implantação. Antes disso, os números vêm da execução do script de [`_analises/`](_analises/analises.ps1), que já roda com guarda de conferência: se a soma não bater em R$ 805.879,35, ele **aborta em vez de reportar** — a proteção contra a armadilha de separador decimal que infla a receita em 2,26×.

Quando os dados de agendamento chegarem, é o mesmo script que se estende: os indicadores 7, 8 e 9 passam de "cego" a medidos, e a linha de base real da operação finalmente existe.
