# 03 — Segmentação e réguas de relacionamento

Como a base é classificada, com que cortes, e o que acontece com cada segmento.

---

## 1. Por que não é RFM

RFM (Recência, Frequência, Monetário) é o padrão de mercado e **quebra em estética**. Não por teoria — pelos dados desta clínica:

**Frequência é estruturalmente baixa.** Dos 509 clientes pagantes, **327 (64,2%) compraram exatamente uma vez**. Um score de frequência de 1 a 5 colapsa dois terços da base no mesmo balde e não separa nada.

| Compras pagas | Clientes | % dos pagantes |
|---|---:|---:|
| 1 | 327 | 64,2% |
| 2–3 | 135 | 26,5% |
| 4–5 | 29 | 5,7% |
| 6–10 | 17 | 3,3% |
| 11+ | 1 | 0,2% |

**Recência absoluta não significa a mesma coisa para produtos diferentes.** Medido em A3, o intervalo real (p75) entre compras varia de **33 dias** (endolaser) a **164 dias** (injetáveis faciais) — uma diferença de 5×. Sessenta dias sem voltar é normal para um e abandono para o outro. Um corte único de recência classifica errado os dois.

**RFM ignora onde a pessoa está no protocolo.** Um cliente na 2ª sessão de um pacote de 4 e outro que abandonou depois da 1ª têm R e F idênticos e situações opostas. Um precisa de agenda; o outro, de resgate.

**E RFM não enxerga quem nunca comprou** — justamente os 172 que vieram, foram atendidos e geraram R$ 0.

---

## 2. O modelo: Estágio × Valor × Recência Relativa

Três eixos. Os dois primeiros classificam quem a pessoa é; o terceiro decide **quando** falar com ela.

### Eixo 1 — Estágio de ciclo

Vem direto da posição nos funis. É categórico, não é score.

| Estágio | Definição operacional |
|---|---|
| `Lead` | No Funil 1, sem avaliação realizada |
| `Avaliou e não comprou` | Atendimento registrado, receita total = R$ 0 |
| `Cliente novo` | Exatamente 1 compra paga |
| `Em protocolo` | Protocolo aberto, sessões pendentes |
| `Protocolo concluído` | Todas as sessões realizadas |
| `Recorrente` | 2+ compras pagas em ciclos distintos |
| `Perdido` | Recência relativa > 3,0 e sem resposta a 2 réguas |

### Eixo 2 — Valor (calibrado em A4)

Sobre os 509 clientes pagantes:

| Faixa | Critério | Clientes | % |
|---|---|---:|---:|
| **Topo** | LTV ≥ R$ 3.000 (p90) | 55 | 10,8% |
| **Alto** | R$ 2.000 – R$ 3.000 | 111 | 21,8% |
| **Médio** | R$ 530 – R$ 2.000 | 216 | 42,4% |
| **Entrada** | < R$ 530 (p25) | 127 | 25,0% |

Referência: mediana de LTV **R$ 1.400,00** · média R$ 1.583,26 · máximo R$ 9.199,90.

**Os 55 clientes do topo respondem por 31,4% de toda a receita** (R$ 253.242,25). Cinquenta e cinco pessoas. É uma lista que cabe numa página e hoje ninguém trata de forma diferenciada.

### Eixo 3 — Recência Relativa

```
recencia_relativa = dias desde o último atendimento ÷ ciclo da família do último procedimento
```

Ciclos medidos em A3 (p75 do intervalo real entre compras pagas):

| Família do último procedimento | n | Mediana | **Ciclo (p75)** |
|---|---:|---:|---:|
| INJETÁVEIS FACIAIS | 86 | 42 d | **164 dias** |
| ESTÉTICA FACIAL | 23 | 41 d | **91 dias** |
| CRIOLIPÓLISE — protocolo pré/pós | 64 | 23 d | **72 dias** |
| CRIOLIPÓLISE | 85 | 30 d | **70 dias** |
| DRENAGEM / MASSAGEM | 39 | 27 d | **62 dias** |
| SUPLEMENTO (Morosil) | 40 | 26 d | **53 dias** |
| INJETÁVEIS CORPORAIS | 64 | 21 d | **42 dias** |
| ENDOLASER — protocolo pós | 27 | 22 d | **36 dias** |
| ENDOLASER | 47 | 15 d | **33 dias** |
| *(qualquer família com n < 15)* | — | — | **62 dias** (geral) |

**Por que o p75 e não a mediana:** a régua deve disparar quando o cliente está atrasado em relação à maioria, não no ponto médio. Disparar na mediana significa incomodar metade das pessoas que ainda estão no ritmo normal.

| Faixa | Valor | Leitura |
|---|---|---|
| **No ciclo** | < 1,0 | Comportamento normal. Não incomodar. |
| **Atrasado** | 1,0 – 2,0 | Passou do ponto. Momento certo da régua de recompra. |
| **Dormindo** | 2,0 – 3,0 | Precisa de oferta, não de lembrete. |
| **Frio** | > 3,0 | Campanha ampla, baixa frequência. |

⚠️ Os ciclos vêm de **490 intervalos observados** numa janela de 17 meses. São sólidos para as famílias de topo e frágeis para as de cauda. **Recalcular a cada seis meses** — e obrigatoriamente quando os dados de 2026 entrarem.

---

## 3. Os oito segmentos e suas réguas

Réguas curtas de propósito. Sequência longa em base pequena queima a lista.

### 🔴 1. Avaliou e não comprou — 172 pessoas
**A maior oportunidade barata da base.** Já estiveram fisicamente na clínica; 168 vieram uma única vez; 147 fizeram `AVALIAÇÃO CRIO`. Não existe processo nenhum apontado para elas.

| Quando | Ação |
|---|---|
| D+2 | Mensagem pessoal de quem atendeu: retomar o que foi conversado na avaliação |
| D+7 | Prova social do procedimento avaliado (resultado real, mesma queixa) |
| D+21 | Condição com prazo — a única oferta da régua |
| D+45 | Encerra. Vai para `Frio`. |

Meta inicial: converter 10% em 90 dias = **17 clientes**. A um ticket mediano de R$ 707,90, ≈ **R$ 12.000** sem R$ 1 de mídia.

### 🔴 2. Cliente novo, atrasado — o maior vazamento
327 clientes compraram uma vez e pararam. Filtrados por recência relativa entre 1,0 e 2,0, viram uma lista pequena e acionável a cada semana, em vez de um disparo de 327 pessoas.

| Quando | Ação |
|---|---|
| RR = 1,0 | Contato do profissional que atendeu, ancorado no resultado |
| RR = 1,3 | Oferta da **expansão natural** da família dele (§4) |
| RR = 1,8 | Última tentativa, condição melhor |
| RR > 2,0 | Vai para `Dormindo` |

### 🟢 3. Topo — 55 clientes, 31,4% da receita
Não recebem régua automática. Recebem **contato nominal**: aniversário, novidade antes de todo mundo, prioridade de agenda. Um único cliente do topo vale, em média, mais que 10 de entrada.

### 🟢 4. Em protocolo
Régua **operacional**, não comercial: confirmação D-1, lembrete de intervalo entre sessões, alerta ao operacional se a próxima sessão passar de 1,5× o intervalo previsto. Objetivo é conclusão, não venda.

### 🟢 5. Protocolo concluído
O único momento da jornada em que o cliente está com o resultado na mão. Três ações em sequência: registrar resultado + NPS → **pedir indicação** → oferecer a expansão natural.

### 🟡 6. Recorrente no ciclo
Não incomodar. Só comunicação de valor: conteúdo, novidade, agenda. Frequência máxima: 1 contato/mês.

### 🟡 7. Dormindo (RR 2,0–3,0)
Campanha mensal por família, com oferta real. Aqui a oferta é o instrumento — lembrete não traz de volta quem já passou de duas vezes o ciclo.

### ⚪ 8. Frio / Perdido (RR > 3,0)
Máximo 1 contato por trimestre, em campanha ampla. **Não deletar** — é a base do lookalike do Meta e a lista de campanhas sazonais.

---

## 4. A expansão natural de cada família (A2)

Qual é o próximo procedimento provável, medido no histórico real:

| Entrou por | Clientes | Recompraram | % | Expansão mais frequente |
|---|---:|---:|---:|---|
| CRIOLIPÓLISE | 217 | 64 | 29,5% | mais criolipólise · protocolo pré/pós |
| CRIOLIPÓLISE — protocolo | 132 | 47 | 35,6% | criolipólise · protocolo |
| ENDOLASER | 117 | 45 | 38,5% | **injetáveis faciais** · drenagem |
| SUPLEMENTO (Morosil) | 107 | 42 | 39,3% | criolipólise · drenagem |
| **INJETÁVEIS FACIAIS** | 83 | 38 | **45,8%** | injetáveis faciais · estética facial |
| ENDOLASER — protocolo pós | 70 | 25 | 35,7% | injetáveis faciais · drenagem |
| DRENAGEM / MASSAGEM | 37 | 12 | 32,4% | drenagem · injetáveis corporais |
| **INJETÁVEIS CORPORAIS** | 34 | 20 | **58,8%** | injetáveis corporais · injetáveis faciais |
| ESTÉTICA FACIAL | 32 | 6 | 18,8% | estética facial · injetáveis corporais |

**Três leituras que mudam a régua:**

1. **Injetáveis retêm muito mais que corporais.** Corporais 58,8% e faciais 45,8%, contra 29,5% da criolipólise — que é onde vai 58,8% da verba de mídia. Quem entra por injetável volta; quem entra por criolipólise, na maioria, não.
2. **Endolaser é ponte para injetáveis faciais.** É a expansão mais frequente de quem entra por endolaser — e injetáveis faciais é a família de maior ciclo (164 dias) e melhor retenção. Endolaser já tem o dobro do ROAS da criolipólise (13,32 vs 7,01) e recebe 2,5× menos verba.
3. **Morosil é o item de maior receita da clínica** (R$ 240.049,90), aparece em 82 vendas casadas com endolaser, **não tem campanha nenhuma** e **zero menções** no corpus de WhatsApp. É venda presencial pura, invisível a toda a análise de mídia.

---

## 5. Governança das réguas

| Regra | Valor |
|---|---|
| Frequência máxima por pessoa | 1 contato a cada 7 dias, qualquer régua |
| Segmentos simultâneos | 1 — o de maior prioridade vence |
| Pausa automática | Qualquer resposta do cliente pausa toda régua e cria tarefa humana |
| Horário de disparo | 9h–17h, seg–sex |
| Recálculo dos segmentos | Diário |
| Recalibração dos ciclos e cortes | Semestral, ou quando entrarem dados novos |

**Por que 9h–17h:** 81,5% das mensagens do corpus acontecem entre 8h e 17h; os picos são 14h e 16h; fim de semana é 8,1% do volume. Disparar fora disso é falar com ninguém.

⚠️ **Consentimento antes de tudo.** `Termos do usuário = Não` em 99,9% dos 6.374 contatos. Ligar réguas automáticas sobre essa base sem resolver a base legal é criar risco de LGPD em escala. **É pré-requisito da onda 4, não detalhe jurídico posterior.**

---

## 6. O que este modelo não resolve

- **Não enxerga no-show.** Quem agendou e não veio não entra em segmento nenhum — não existe registro. Depende do novo sistema de agendamento.
- **Os ciclos são de 17 meses de dados.** Famílias de cauda têm n pequeno; tratar como direcional.
- **Não mede satisfação hoje.** O NPS do Funil 3 é dado novo — até existir, "cliente satisfeito" é suposição.
- **Não separa quem parou por resultado ruim de quem parou por preço.** Só o motivo de perda estruturado, acumulado por alguns meses, responde isso.
