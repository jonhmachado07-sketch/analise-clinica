# Resultados das analises A1-A7

> Gerado por _analises/analises.ps1 em 12/08/2026.
> Fonte: Base Unificada - Clinica Expert.xlsx. Guarda de conferencia: **5 de 5 OK**
> (soma R\$ 805.879,35 - 1.423 linhas - 530 de valor zero - 991 clientes - 6.374 contatos).

⚠️ **Janela:** vendas vao de 09/07/2024 a 25/12/2025. Nada aqui cobre 2026.

---

## A1 - De-para canonico: 72 itens -> 10 familias

Cada linha de venda pode conter varios itens; a receita da linha e atribuida
integralmente a **cada** familia presente. A coluna de receita por familia, portanto,
**soma mais que o total** - serve para ranquear, nunca para somar.

| Familia canonica | Itens originais | Linhas | Linhas pagas | Receita atribuida |
|---|---:|---:|---:|---:|
| CRIOLIPOLISE | 14 | 302 | 285 | R$ 302.030,50 |
| ENDOLASER | 3 | 142 | 141 | R$ 256.997,80 |
| INJETAVEIS FACIAIS | 11 | 191 | 188 | R$ 244.244,85 |
| SUPLEMENTO (Morosil) | 2 | 124 | 124 | R$ 243.449,90 |
| CRIOLIPOLISE - protocolo pre/pos | 7 | 215 | 185 | R$ 216.580,70 |
| ENDOLASER - protocolo pos | 4 | 105 | 97 | R$ 176.391,50 |
| AVALIACAO (entrada, majoritariamente gratuita) | 6 | 504 | 42 | R$ 33.933,60 |
| INJETAVEIS CORPORAIS | 12 | 104 | 100 | R$ 33.026,45 |
| ESTETICA FACIAL | 7 | 71 | 70 | R$ 12.610,00 |
| DRENAGEM / MASSAGEM | 6 | 98 | 92 | R$ 11.670,00 |

**Cobertura:** 72 itens originais mapeados em 10 familias - nenhum orfao.

---

## A6 - Os clientes que vieram e nao pagaram

| Grupo | Clientes |
|---|---:|
| Atendidos com receita > 0 (**pagantes**) | 509 |
| Atendidos com receita = 0 | 172 |
| **Total com algum atendimento** | 681 |

**Quantas vezes esse grupo esteve fisicamente na clinica:**

| Visitas | Clientes |
|---|---:|
| 1 visita | 168 |
| 2-3 visitas | 2 |
| 4+ visitas | 2 |

**O que eles fizeram (top 8):**

| Item | Ocorrencias |
|---|---:|
| AVALIAÇÃO CRIO | 147 |
| AVALIAÇÃO FACIAL | 13 |
| PÓS CRIO | 7 |
| INTRADERMOTERAPIA [ENZIMAS] | 4 |
| CRIO TURBO | 4 |
| AVALIAÇAO ENDOLASER | 3 |
| Pós endolaser | 3 |
| 2x PÓS CRIO | 2 |

### A metrica-mae, medida pela primeira vez

| Indicador | Valor |
|---|---:|
| Clientes com ao menos uma avaliacao gratuita registrada | 395 |
| Destes, pagaram **algum** procedimento depois da avaliacao | 186 |
| **Conversao avaliacao -> procedimento pago** | **47,1%** |

⚠️ Este numero e o **piso**, nao a taxa real: so enxerga quem compareceu e teve
atendimento registrado. Quem agendou avaliacao e nao apareceu nao existe em fonte
nenhuma (mapa_de_dados/05, lacuna 2). A taxa verdadeira so aparece quando o
sistema de agendamento entregar o status de comparecimento.

---

## A4 - Distribuicao de LTV: os cortes do eixo Valor

Sobre os **509 clientes pagantes** (receita > 0):

| Estatistica | Valor |
|---|---:|
| Minimo | R$ 100,00 |
| p25 | R$ 530,00 |
| **Mediana** | **R$ 1.400,00** |
| p75 | R$ 2.000,00 |
| p90 | R$ 3.000,00 |
| Maximo | R$ 9.199,90 |
| Media | R$ 1.583,26 |

**Cortes adotados para o eixo Valor** (§3 do 03_SEGMENTACAO_E_REGUAS.md):

| Faixa | Criterio | Clientes |
|---|---|---:|
| Topo | LTV >= R$ 3.000,00 (p90) | 55 |
| Alto | R$ 2.000,00 a R$ 3.000,00 | 111 |
| Medio | R$ 530,00 a R$ 2.000,00 | 216 |
| Entrada | < R$ 530,00 (p25) | 127 |

**Concentracao:** os 55 clientes do topo respondem por 31,4% da receita (R$ 253.242,25 de R$ 805.879,35).

---

## A3 - Intervalo real entre compras, por familia

Dias entre um atendimento pago e o **proximo atendimento pago** do mesmo cliente,
indexado pela familia do atendimento anterior. E o denominador do eixo
**Recencia Relativa** do modelo de segmentacao.

| Familia (do atendimento anterior) | n | Mediana | p75 | **Ciclo adotado** |
|---|---:|---:|---:|---:|
| INJETAVEIS FACIAIS | 86 | 42 d | 164 d | **164 dias** |
| CRIOLIPOLISE | 85 | 30 d | 70 d | **70 dias** |
| CRIOLIPOLISE - protocolo pre/pos | 64 | 23 d | 72 d | **72 dias** |
| INJETAVEIS CORPORAIS | 64 | 21 d | 42 d | **42 dias** |
| ENDOLASER | 47 | 15 d | 33 d | **33 dias** |
| SUPLEMENTO (Morosil) | 40 | 26 d | 53 d | **53 dias** |
| DRENAGEM / MASSAGEM | 39 | 27 d | 62 d | **62 dias** |
| ENDOLASER - protocolo pos | 27 | 22 d | 36 d | **36 dias** |
| ESTETICA FACIAL | 23 | 41 d | 91 d | **91 dias** |
| AVALIACAO (entrada, majoritariamente gratuita) | 15 | 16 d | 108 d | **108 dias** |

**Geral (todas as familias):** n = 490 - mediana 26 dias - p75 62 dias.

O ciclo adotado e o **p75**, nao a mediana: a regua deve disparar quando o cliente
esta atrasado em relacao a maioria, nao no ponto medio. Familias com n < 15 nao
recebem ciclo proprio e herdam o ciclo geral.

---

## A2 - Porta de entrada e expansao

Familia do **primeiro atendimento pago** de cada cliente, e o que ele comprou depois.

| Familia de entrada | Clientes | Recompraram | % | Expansao mais frequente |
|---|---:|---:|---:|---|
| CRIOLIPOLISE | 217 | 64 | 29,5% | CRIOLIPOLISE (41) - CRIOLIPOLISE - protocolo pre/pos (34) |
| CRIOLIPOLISE - protocolo pre/pos | 132 | 47 | 35,6% | CRIOLIPOLISE (30) - CRIOLIPOLISE - protocolo pre/pos (22) |
| ENDOLASER | 117 | 45 | 38,5% | INJETAVEIS FACIAIS (31) - DRENAGEM / MASSAGEM (17) |
| SUPLEMENTO (Morosil) | 107 | 42 | 39,3% | CRIOLIPOLISE (21) - DRENAGEM / MASSAGEM (16) |
| INJETAVEIS FACIAIS | 83 | 38 | 45,8% | INJETAVEIS FACIAIS (44) - ESTETICA FACIAL (14) |
| ENDOLASER - protocolo pos | 70 | 25 | 35,7% | INJETAVEIS FACIAIS (12) - DRENAGEM / MASSAGEM (11) |
| DRENAGEM / MASSAGEM | 37 | 12 | 32,4% | DRENAGEM / MASSAGEM (18) - INJETAVEIS CORPORAIS (7) |
| INJETAVEIS CORPORAIS | 34 | 20 | 58,8% | INJETAVEIS CORPORAIS (26) - INJETAVEIS FACIAIS (13) |
| ESTETICA FACIAL | 32 | 6 | 18,8% | ESTETICA FACIAL (4) - INJETAVEIS CORPORAIS (3) |
| AVALIACAO (entrada, majoritariamente gratuita) | 26 | 10 | 38,5% | INJETAVEIS FACIAIS (11) - INJETAVEIS CORPORAIS (7) |

---

## A7 - Venda casada: o que sai junto na mesma linha

| Combinacao (em linhas pagas) | Ocorrencias |
|---|---:|
| CRIOLIPOLISE + CRIOLIPOLISE - protocolo pre/pos | 138 |
| ENDOLASER + SUPLEMENTO (Morosil) | 82 |
| ENDOLASER + ENDOLASER - protocolo pos | 82 |
| ENDOLASER - protocolo pos + SUPLEMENTO (Morosil) | 77 |
| CRIOLIPOLISE + SUPLEMENTO (Morosil) | 49 |
| CRIOLIPOLISE - protocolo pre/pos + SUPLEMENTO (Morosil) | 46 |
| AVALIACAO (entrada, majoritariamente gratuita) + INJETAVEIS FACIAIS | 23 |
| INJETAVEIS CORPORAIS + INJETAVEIS FACIAIS | 9 |
| CRIOLIPOLISE + INJETAVEIS FACIAIS | 8 |
| CRIOLIPOLISE + ENDOLASER | 8 |

**343 de 893 linhas pagas (38,4%) tem mais de um item** - a venda casada nao e excecao, e o padrao.

---

## A5 - Do cadastro no CRM ate a primeira compra

Dias entre Entrou no CRM em e Primeira Compra, por canal. Define os SLA do
Funil 1 e a janela a partir da qual o lead deve ser considerado morto.

| Canal | n | Mediana | p75 | p90 | <= 7 dias | <= 30 dias |
|---|---:|---:|---:|---:|---:|---:|
| Meta Ads | 225 | 6 d | 14 d | 51 d | 60% | 86% |
| Não informado | 46 | 4 d | 21 d | 29 d | 59% | 91% |
| Instagram Orgânico | 29 | 7 d | 20 d | 67 d | 52% | 90% |
| Indicação | 28 | 8 d | 17 d | 70 d | 46% | 79% |
| Reativação | 8 | 48 d | 192 d | 257 d | 0% | 0% |
| Google Meu Negócio | 5 | 6 d | 11 d | 17 d | 60% | 100% |
| **Todos** | **348** | **6 d** | **17 d** | **58 d** | **57%** | **84%** |

---

## Anexo - Distribuicao de compras pagas por cliente

| Compras pagas | Clientes | % dos pagantes |
|---|---:|---:|
| 1 | 327 | 64,2% |
| 2-3 | 135 | 26,5% |
| 4-5 | 29 | 5,7% |
| 6-10 | 17 | 3,3% |
| 11+ | 1 | 0,2% |

---

## Notas de grao - por que alguns numeros diferem do mapa_de_dados

Nenhuma divergencia abaixo e erro. Sao contagens de coisas diferentes, e
misturar duas delas na mesma conta produz resultado errado.

| Aqui | mapa_de_dados | Motivo |
|---|---|---|
| 681 clientes com atendimento | 683 | Aqui o grao e **telefone** (chave canonica, 04 §1); la e **nome**. 683 nomes dividem 681 telefones (provavel parentesco ou recadastro). |
| 509 pagantes | 511 | Mesmo motivo. |
| Soma das familias > R\$ 805.879,35 | - | Linha com varios itens e creditada a cada familia. Ranquear, nunca somar. |
| Soma da coluna 'Clientes' de A2 > 509 | - | Primeira compra com varios itens conta em cada familia de entrada. |

**O que nao esta aqui e nao pode ser inferido:** comparecimento, no-show,
cancelamento, agendamento, atendente real, satisfacao e resultado clinico.
Nenhuma das tres fontes registra qualquer um deles.

