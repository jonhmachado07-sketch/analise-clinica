# 05 — Implantação em quatro ondas

Ordem que maximiza retorno por esforço. Cada onda entrega algo que funciona sozinho — nada aqui depende de a onda seguinte acontecer.

---

## Onda 1 — Semana 1: o que custa quase nada

Quatro itens de esforço trivial que destravam a leitura de canal e o funil. **Nenhum exige sistema novo, desenvolvimento ou verba.**

| # | Ação | Quem | Resultado |
|---|---|---|---|
| 1 | **Definir o que é `REATIVAÇÕES`** com a operação | Gestão | Corrige a leitura de R$ 141.805,40 e do CAC de um canal inteiro |
| 2 | **Exportar *leads* do Kommo** (não contatos) | Gestão | Etapa de funil, tempo em etapa, valor, motivo de perda — o dado que bloqueia o projeto |
| 3 | **Tornar `Origem` obrigatória** no cadastro | Kommo | Fecha os 27,5% de contatos cegos |
| 4 | **Criar campo estruturado de atendente** | Kommo | Torna possível a primeira análise de desempenho por pessoa da história da clínica |

**Duas verificações técnicas que precisam sair nesta semana**, porque decidem tudo depois:

- O Kommo grava o **`ctwa_clid`** no lead vindo do Meta?
- O Kommo expõe o **histórico de mensagens** do WhatsApp via export ou API?

A segunda resolve de uma vez três problemas que hoje custam caro: cobertura total em vez de amostra de 0,55%, vínculo nativo com o contato (dispensando match por telefone) e carimbo de atendente real.

### E a investigação que vale mais que qualquer otimização

**6.620 conversas iniciadas no Meta contra 3.385 contatos de origem Meta no CRM.** Metade some. Descobrir por quê — falta de resposta, desqualificação ou falha da automação — é o item de maior retorno da onda 1, e não é configuração: é investigação.

---

## Onda 2 — Semanas 2–3: o funil operando

| Ação | Detalhe |
|---|---|
| Criar os **4 pipelines** no Kommo | Conforme [`01_FUNIS_E_ETAPAS.md`](01_FUNIS_E_ETAPAS.md) |
| **Motivos de perda** como lista fechada | 8 opções no F1, 6 no F2 — sem campo livre |
| **SLA de 10 min** com alerta automático | Alerta dispara em 10 min; escalona em 30 |
| **Ligar o `ctwa_clid`** Meta → Kommo | Não recupera o passado; para de perder o futuro |
| **Handoffs automáticos** F1→F2 e F2→F3 | Sem passo manual (`00_ARQUITETURA.md` §4) |
| Consentimento LGPD no cadastro | `Termos do usuário` = `Não` em 99,9% de 6.374 pessoas |

**Critério de pronto:** um lead novo entra, atravessa as cinco etapas do Funil 1 e chega ao Funil 2 sem ninguém mover card manualmente.

---

## Onda 2½ — Semanas 3–4: o lastro no ar

Roda em paralelo com a onda 3. É o que transforma Kommo e Meta em fontes de entrada e o banco em fonte de verdade — ver [`06_MODELO_DE_DADOS.md`](06_MODELO_DE_DADOS.md).

| Ação | Detalhe |
|---|---|
| Subir o Postgres com as **14 tabelas** | Nada aqui é grande: ~45 mil eventos na carga histórica |
| Cadastrar os **34 tipos de evento** e os **6 namespaces de tag** | Catálogo fechado: evento ou tag fora dele é rejeitado na escrita |
| **Ingestão Kommo e Meta** com chave de idempotência | Rodar o import duas vezes não pode duplicar nada |
| **Carga histórica** da xlsx consolidada | `ocorrido_em` real, `registrado_em` = data da carga — lastro contínuo, sem fronteira artificial |
| **Motor de expectativas** | O que gera a fila de trabalho do dia (§5 do doc 06) |

**Critério de pronto:** a consulta do lastro de uma pessoa (§8 do doc 06) devolve, numa tela, o que hoje exige abrir três planilhas e um zip de WhatsApp.

---

## Onda 3 — Semanas 4–6: fim dos pontos cegos

Depende dos dados do novo sistema de agendamento.

| Ação | Destrava |
|---|---|
| Aplicar o **de-para canônico** dos 72 itens (A1) no cadastro de procedimentos | Toda análise por produto, e o eixo de recência relativa |
| Integrar **agendamento ↔ CRM** pelo `id_agendamento` | O elo lead → agenda → venda |
| **Status de comparecimento** na recepção | Separa no-show de "não vendeu" |
| `sessao_n`/`total_sessoes` no cadastro de protocolo | Separa venda de execução |

**Critério de pronto:** o indicador 9 do painel — avaliação → procedimento pago — sai de "piso de 30,4%" para taxa medida de verdade.

⚠️ Se os dados de agendamento atrasarem, as ondas 1, 2 e 4 seguem sem eles. Só os indicadores 7, 8 e 9 ficam esperando.

---

## Onda 4 — Semanas 7+: relacionamento e painel

| Ação | Detalhe |
|---|---|
| Motor de **segmentos** rodando diariamente | Estágio × Valor × Recência Relativa ([`03_SEGMENTACAO_E_REGUAS.md`](03_SEGMENTACAO_E_REGUAS.md)) |
| **Régua 1: avaliou e não comprou** | 172 pessoas — começar por esta |
| **Régua 2: cliente novo atrasado** | 327 clientes de compra única, filtrados por RR |
| **Pedido de indicação** no Funil 3 | O canal que converte 77,8% e tem 0,6% do topo |
| **Painel** dos 15 indicadores | [`04_PAINEL_KPI.md`](04_PAINEL_KPI.md) |
| Tratamento nominal do **Topo** | 55 clientes = 31,4% da receita |

**Por que a régua dos 172 vem primeiro:** é a menor lista, o público mais quente (já esteve fisicamente na clínica), o menor custo e o teste mais rápido de que o motor funciona. Meta: 10% em 90 dias ≈ R$ 12.000 sem R$ 1 de mídia.

---

## Resumo por esforço e retorno

| Onda | Esforço | Retorno | Depende de terceiros? |
|---|---|---|---|
| **1** | Quase zero | **Alto** — destrava funil, canal e verba | Não |
| **2** | Configuração | Alto — o funil passa a existir | Não |
| **3** | Médio | **O maior** — acaba com os dois pontos cegos | **Sim** — sistema de agendamento |
| **4** | Médio | Alto e recorrente — retenção e indicação | Não |

---

## Gatilho de migração de stack

A decisão foi manter o Kommo. Isso não é permanente — é a leitura correta **hoje**, porque o custo de migrar antes de saber o que se precisa é maior que o de reconfigurar.

**Migrar de CRM só se, na onda 1, ficar comprovado que o Kommo:**

1. **não** grava o `ctwa_clid` no lead — sem isso, atribuição por campanha no nível da pessoa é impossível e o problema não é de configuração, é de plataforma; **ou**
2. **não** expõe o histórico de mensagens via export/API — o que mantém a conversa, onde a venda acontece, permanentemente fora de qualquer medição; **ou**
3. **não** suporta os 4 pipelines com automação de handoff — o que obrigaria a operação manual que este desenho existe para evitar.

**Um item isolado não justifica migrar.** Dois já justificam avaliar. Os três, migrar.

**Se migrar, a ordem não muda:** este desenho é agnóstico de ferramenta. Os quatro funis, os doze eventos, as cinco chaves e o modelo de segmentação valem em qualquer CRM. O que muda é onde cada campo mora.

**O que nunca migra:** as cinco chaves de amarração (`02_TRACKING.md` §2). Elas são do negócio, não do sistema. Qualquer ferramenta nova precisa aceitá-las no dia um, ou o histórico se perde na troca — exatamente o que já aconteceu quando o CRM começou a ser usado em abril de 2025 e deixou 186 clientes anteriores sem vínculo nenhum.

---

## O risco real deste projeto

Não é técnico. Todas as ondas são executáveis com o que a clínica já tem.

O risco é **disciplina de operação**: mover card, preencher campo, seguir régua, todo dia, por meses. O `mapa_de_dados` já mostra o que acontece quando isso não é sustentado — cinco campos de anotação vazios em 6.378 linhas, consentimento não capturado em 99,9% dos casos, e o campo de atendente inutilizável em três fontes diferentes ao mesmo tempo.

**Mitigação:** os indicadores 3 e 5 do painel são indicadores de *processo*, não de resultado. Se `% de origem preenchida` cai ou o p90 de resposta sobe, a operação está soltando — e isso aparece semanas antes de aparecer na receita.
