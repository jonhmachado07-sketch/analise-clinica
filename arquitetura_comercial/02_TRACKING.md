# 02 — Tracking: do anúncio à nota fiscal

O que é registrado, onde nasce, em que campo, em que sistema. Este documento é o contrato entre marketing, comercial, operação e financeiro.

> **Este documento é o "o quê". O "como se guarda" está em [`06_MODELO_DE_DADOS.md`](06_MODELO_DE_DADOS.md)** — onde os 12 momentos abaixo viram 34 tipos de evento num lastro imutável, com resolução de identidade, tags versionadas e expectativas cíclicas.

---

## 1. A cadeia completa

Doze eventos. Cada um tem um dono, um sistema e um campo. Evento sem dono não acontece.

| # | Momento | Evento | Campos obrigatórios | Sistema | Dono |
|---|---|---|---|---|---|
| 1 | Anúncio exibido/clicado | `ad_clique` | `campaign_id` · `adset_id` · `ad_id` | Meta | Mídia |
| 2 | Clique no botão do WhatsApp | `conversa_iniciada` | **`ctwa_clid`** · `ad_id` | Meta → Kommo | Mídia |
| 3 | Contato criado | `lead_criado` | `origem` **(obrigatório)** · `ctwa_clid` · `campanha` · `produto_anunciado` · `criado_em` | Kommo | Automação |
| 4 | Primeira resposta humana | `primeiro_contato` | `timestamp` · **`atendente`** | Kommo | Atendimento |
| 5 | Qualificação | `lead_qualificado` | `motivacao` · `ja_fez_procedimento` · `regiao_interesse` · `contraindicacao` | Kommo | Atendimento |
| 6 | Agendamento marcado | `agendamento_criado` | `id_agendamento` · `data_hora_marcacao` · `data_hora_agendada` · `procedimento` · `profissional` | Agenda | Atendimento |
| 7 | Desfecho do agendamento | `status_agendamento` | `compareceu` · `no_show` · `cancelado_cliente` · `cancelado_clinica` · `remarcado` + `id_agendamento_origem` | Agenda | Recepção |
| 8 | Proposta | `proposta_apresentada` | `valor_tabela` · `valor_proposto` · `protocolo` · `total_sessoes` | Kommo | Vendedora |
| 9 | Venda | `venda_fechada` | `valor_praticado` · `desconto` · `forma_pagamento` · `parcelas` · `id_agendamento` | Agenda/financeiro | Vendedora |
| 10 | Sessão realizada | `sessao_realizada` | `sessao_n` / `total_sessoes` · **`cod_procedimento`** · `profissional` | Agenda | Operacional |
| 11 | Resultado | `resultado_registrado` | `medida_foto` · `nps` · `data` | Agenda/form | Operacional |
| 12 | Fiscal | `nf_emitida` | `numero` · `valor` · `cpf` · `competencia` | Financeiro | Financeiro |

**Onde a cadeia quebra hoje:** eventos 2, 6, 7, 8, 10 e 11 não existem em fonte nenhuma. Metade da cadeia.

---

## 2. As cinco chaves de amarração

Sem chave comum, doze eventos viram doze planilhas soltas — que é exatamente a situação atual.

| Chave | Amarra | Formato canônico | Cobertura hoje |
|---|---|---|---|
| **`telefone_normalizado`** | tudo com tudo | **8 últimos dígitos**, só números | 100% em Vendas · 85,6% no CRM |
| `cpf` | cadastro ↔ CRM ↔ fiscal | só dígitos | quase total no cadastro · **7,6% no CRM** |
| **`ctwa_clid`** | anúncio ↔ pessoa | string do Meta | **0% — não existe** |
| `id_agendamento` | agenda ↔ venda ↔ sessão | id do sistema | **0% — não existe** |
| `cod_procedimento` | produto ↔ receita ↔ ciclo | código, não texto livre | **0% — 72 strings sujas** |

### Por que 8 dígitos no telefone

O Brasil adicionou o nono dígito em momentos diferentes por região, e as fontes têm registros de épocas distintas. Comparar o número inteiro faz o mesmo cliente aparecer duas vezes; com 7 dígitos a colisão entre pessoas diferentes deixa de ser desprezível numa base de 6.374. **Os 8 últimos são estáveis** — regra herdada e reconferida do `mapa_de_dados/04` §1, testada em 10 de 10 casos sem falso positivo nem falso negativo.

⚠️ Cada fonte escreve o telefone de um jeito: `'+5527992387855` no CRM (com apóstrofo), `+55 (27) 99920-8977` no cadastro, `+55 27 99654‑3844` no WhatsApp (com **hífen tipográfico U+2011**, que quebra comparação literal). Normalizar sempre antes de comparar.

### `cod_procedimento`: o de-para dos 72 itens

Os 72 valores de `Itens` colapsam em **10 famílias** (A1). Não é cosmético: é o que permite calcular ciclo de recompra, ROAS por produto e qualquer análise de expansão.

| Família canônica | Itens originais | Receita atribuída |
|---|---:|---:|
| CRIOLIPÓLISE | 14 | R$ 302.030,50 |
| ENDOLASER | 3 | R$ 256.997,80 |
| INJETÁVEIS FACIAIS | 11 | R$ 244.244,85 |
| SUPLEMENTO (Morosil) | 2 | R$ 243.449,90 |
| CRIOLIPÓLISE — protocolo pré/pós | 7 | R$ 216.580,70 |
| ENDOLASER — protocolo pós | 4 | R$ 176.391,50 |
| AVALIAÇÃO (entrada) | 6 | R$ 33.933,60 |
| INJETÁVEIS CORPORAIS | 12 | R$ 33.026,45 |
| ESTÉTICA FACIAL | 7 | R$ 12.610,00 |
| DRENAGEM / MASSAGEM | 6 | R$ 11.670,00 |

⚠️ **A coluna de receita soma mais que R$ 805.879,35** — linha com vários itens é creditada a cada família. Serve para ranquear, nunca para somar. A regra de mapeamento está codificada na função `Familia()` de [`_analises/analises.ps1`](_analises/analises.ps1) e é auditável item a item.

**No sistema:** cada procedimento cadastrado ganha um código e uma família. O texto livre em `Itens` para de existir na origem — é a única forma de não recriar a sujeira.

---

## 3. As quatro configurações de custo quase zero

O `mapa_de_dados/05` identifica quatro lacunas que custam quase nada e destravam o resto. Elas são a onda 1 da implantação.

| # | O que fazer | Esforço | O que destrava |
|---|---|---|---|
| 1 | **Exportar *leads*, não contatos**, do Kommo | Trivial — é escolher o objeto certo no export | Etapa de funil, tempo em etapa, valor, motivo de perda. Hoje toda conversão é inferida *a posteriori* |
| 2 | **Ligar o `ctwa_clid`** no fluxo Meta → Kommo | Baixo — configuração | Atribuição por campanha no nível da pessoa. Não recupera o passado; para de perder o futuro |
| 3 | **Tornar `Origem` obrigatória** no cadastro | Trivial | Os 27,5% de contatos cegos — que são, aliás, o grupo de **maior LTV da base** (R$ 1.720,48) |
| 4 | **Fechar a definição de `REATIVAÇÕES`** | Trivial — é uma conversa | A leitura de um canal inteiro e de R$ 141.805,40 |

### E a quinta, que não é configuração

**Metade das conversas do Meta não vira contato:** 6.620 conversas iniciadas contra 3.385 contatos de origem Meta no CRM. É o maior vazamento medido de toda a operação e ninguém sabe se some por falta de resposta, desqualificação ou falha da automação. **Investigar isso vale mais que qualquer otimização de criativo** — é metade do topo do funil pago.

---

## 4. Campos que precisam existir e hoje não existem

| Campo | Onde | Por que | Custo |
|---|---|---|---|
| `atendente` (estruturado) | Kommo, por etapa | Nenhuma das três fontes registra quem atendeu. `Responsável` é constante em 100% das 1.423 vendas; no CRM é quase monocolor; no WhatsApp o atendente só assina em texto livre — Mayara, Vanessa, Bandeira, Lorrainy e Kátia atendem sob a mesma identidade | Baixo |
| `motivo_perda` (lista fechada) | Kommo, F1 e F2 | Os `Nota 1..5` estão vazios em 6.378 de 6.378 linhas. Todo o contexto qualitativo do lead vive só na conversa | Trivial |
| `cpf` no cadastro do lead | Kommo | Levaria a junção CRM↔vendas de 81,2% a ~100% | Baixo |
| `consentimento_lgpd` | Kommo | `Termos do usuário` = `Não` em **99,9%** de 6.374 pessoas numa base ativa de comunicação. É risco jurídico, não questão de dado | Trivial |
| `sessao_n` / `total_sessoes` | Agenda | Distingue **venda** de **execução**. Sem isso, um pacote de 4 sessões parece 4 compras ou 1, dependendo de como se conta | Médio |

---

## 5. Especificação do que pedir ao novo sistema de agendamento

Herdado de `mapa_de_dados/05` §3 e mantido sem alteração — é a especificação certa.

**Tabela de agendamentos** (um registro por agendamento, não por atendimento realizado):
`id_agendamento` · `telefone` · `cpf` · `nome` · `data_hora_agendada` · `data_hora_marcacao` · `procedimento_agendado` · **`status`** · `motivo_cancelamento` · `id_agendamento_origem` · `profissional` · `unidade`

**Tabela de atendimentos realizados** — o formato de `Vendas Detalhadas` mais quatro adições: `id_agendamento`, `cod_procedimento` canônico, `sessao_n`/`total_sessoes`, e separação explícita entre avaliação gratuita e procedimento pago.

**Financeiro, se disponível:** forma de pagamento, parcelamento, desconto, valor de tabela vs. praticado. O corpus de WhatsApp mostra `cartão` (20 menções), `parcel` (9) e `pix` (7) — a negociação de pagamento existe e não é medida em lugar nenhum.

**Janela:** a partir de 25/12/2025, para emendar sem sobreposição. Série histórica completa é melhor — permite reconciliar a consolidação anterior.

⚠️ **O campo mais importante do pedido inteiro é `status`.** Sem ele, "não vendeu" e "não apareceu" continuam sendo a mesma linha em branco.

---

## 6. Regras de precedência quando as fontes divergirem

Mantidas de `mapa_de_dados/04` §4, porque continuam certas:

| Campo | Fonte de verdade |
|---|---|
| Receita, valor, ticket | `Vendas Detalhadas` → agregado em `Clientes Unificados` |
| Idade / nascimento | Cadastro da clínica (88% de preenchimento contra 8% no CRM) |
| CPF | Cadastro da clínica |
| Telefone | Vendas (100%) → cadastro → CRM |
| Canal de origem | `Origem Consolidada` + `Tipo de Origem` |
| Data de entrada no funil | `Criado em` do CRM |
| Procedimento de interesse | `Procedimento Inicial` do CRM — **interesse declarado, não realizado** |
| Nome | Cadastro da clínica (o CRM tem apelidos, `.` e `...`) |

⚠️ **Três coisas que nunca devem ser feitas**, herdadas do mapa e que seguem valendo no desenho novo: somar a coluna de contatos de `Canais de Aquisição` (56 clientes aparecem em mais de um canal), somar `Receita do Cliente` de `Contatos CRM` (dupla contagem — dá R$ 767.056,05 e não é receita), e misturar grão de contato com grão de cliente na mesma conta (245 vs 174 compradores Meta não é erro, é grão diferente).
