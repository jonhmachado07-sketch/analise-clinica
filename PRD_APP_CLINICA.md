# PRD — App de Operação Clínica (complemento ao CRM)

> Web app enxuto, 5 telas, para uso interno de uma clínica de estética.
> **Não substitui o CRM (Kommo).** O CRM cuida de lead até a venda. Este app cuida do que acontece **depois que o telefone toca**: agenda, atendimento, procedimento e dinheiro.
> Documento para ser entregue a uma IA de desenvolvimento.

---

## 1. Contexto do negócio (leia antes de codar)

Clínica de estética (criolipólise, endolaser, injetáveis, suplemento oral). R$ 805.879,35 faturados em 17 meses, ~992 clientes, ~1.423 atendimentos. Um CRM (Kommo) já gerencia leads e conversas de WhatsApp.

**O que o CRM já resolve e o app NÃO deve refazer:**
- Captação e qualificação de lead, conversas de WhatsApp, funil comercial, motivo de perda, campanhas.

**O que ninguém resolve hoje — e é a razão deste app existir:**

| Buraco | Consequência medida |
|---|---|
| Não existe registro de agendamento | Impossível separar "não vendeu" de "não apareceu". No-show é invisível. |
| Não existe status de comparecimento | A avaliação gratuita é 23% da agenda e ninguém sabe quantas viram venda (piso conhecido: 30,4%) |
| Não existe controle de pagamento/parcela | 37,2% dos atendimentos registrados têm valor R$ 0 misturados com vendas reais; recebível não é acompanhado |
| Não existe histórico clínico nem anamnese | 64,2% dos pagantes compraram uma vez só e não há nada que explique por quê |
| Não existe sessão *n* de *N* | Venda e execução do protocolo são a mesma linha — não se sabe quem abandonou o pacote |
| Nomenclatura de procedimento livre | 72 nomes distintos para ~15 procedimentos reais; nenhuma análise por produto é possível |

**Princípio central:** *o dado nasce do trabalho, não de digitação extra.* Nenhum campo obrigatório pode exigir algo que a recepção ou a avaliadora já não façam naturalmente.

---

## 2. Objetivo do produto

Um app onde a clínica, **em no máximo 3 cliques por evento**, consegue:
1. Marcar e acompanhar a agenda do dia, com status de comparecimento.
2. Lançar todo pagamento recebido, incluindo parcelas futuras.
3. Ver o histórico completo e a anamnese de qualquer cliente.
4. Saber, sem planilha, quanto entrou no mês, quanto falta receber e quanto da agenda compareceu.

**Fora de escopo (v1):** integração automática com o Kommo, emissão fiscal, prontuário assinado digitalmente, app mobile nativo, multi-unidade, controle de estoque, envio de mensagens.

---

## 3. Usuários

| Perfil | Usa | Permissão |
|---|---|---|
| **Recepção** | Agenda, check-in, lançamento de pagamento | Tudo menos Painel financeiro consolidado |
| **Avaliadora / profissional** | Ficha do cliente, anamnese, evolução de sessões | Tudo menos Financeiro |
| **Gestão (dono)** | Todas as telas | Total |

Login simples por e-mail e senha, 3 papéis fixos. Sem cadastro público.

---

## 4. As 5 telas

### Tela 1 — AGENDA (tela inicial)

Visão **Dia** (padrão) e **Semana**, colunas por profissional.

- Novo agendamento: `cliente` (busca ou cria na hora com nome + telefone) · `procedimento` (lista canônica) · `profissional` · `data/hora` · `duração` · `tipo: avaliação | sessão de protocolo | retorno | procedimento avulso` · `observação`.
- Cada card mostra: hora, cliente, procedimento, e um **badge de status**.
- **Status (campo mais importante do app inteiro):** `agendado` → `confirmado` → `compareceu` | `no-show` | `cancelado (cliente)` | `cancelado (clínica)` | `remarcado`.
- Mudar status = **1 clique no card** (menu curto). Check-in de compareceu deve ser o botão mais visível da tela.
- Remarcar gera novo agendamento com `id_agendamento_origem` apontando para o anterior (cadeia preservada, nada é apagado).
- Cancelar exige escolher motivo de uma lista fechada: `imprevisto do cliente` · `remarcou` · `desistiu` · `problema de saúde` · `clínica cancelou` · `não respondeu confirmação`.
- Faixa superior: contadores do dia — agendados / compareceram / no-show / a confirmar.
- Se o agendamento é sessão de protocolo, o card mostra `sessão 3 de 8`.

### Tela 2 — CLIENTES

Lista simples com busca por nome ou telefone. Colunas: nome, telefone, último atendimento, total gasto, nº de compras, saldo em aberto, alerta de anamnese pendente.
Filtros rápidos: `com saldo em aberto` · `sem retorno há mais de 90 dias` · `avaliou e não comprou` · `protocolo em aberto`.
Botão "Novo cliente". Clicar na linha abre a Tela 3.

### Tela 3 — FICHA DO CLIENTE (4 abas)

Cabeçalho fixo: nome, telefone, idade, origem, total gasto, saldo em aberto, botão **"Agendar"**.

**Aba Dados** — nome, telefone (normalizado só para dígitos), CPF, data de nascimento, cidade, origem, observação, consentimento LGPD (checkbox com data).

**Aba Anamnese** — formulário único, versionado (cada preenchimento vira uma versão com data e autor, nada é sobrescrito):
- Queixa principal e expectativa (texto)
- Peso, altura, medidas de interesse (opcional)
- Gestante/amamentando · marcapasso/implantes metálicos · hérnia · doença renal/hepática · alterações de tireoide · diabetes · problemas de coagulação · uso de anticoagulante · alergias · cirurgias prévias · procedimentos estéticos anteriores · medicamentos em uso
- Campo `contraindicação identificada` (sim/não + qual) — se marcado, exibe **alerta vermelho permanente no cabeçalho da ficha**
- Assinatura: nome do profissional e data

**Aba Histórico** — linha do tempo única, ordem decrescente, com todos os eventos do cliente: agendamentos (com status), atendimentos realizados, protocolos e progresso de sessões, pagamentos. Para protocolo em andamento, barra de progresso `sessão n/N` e data prevista da próxima sessão. Campo de evolução por sessão (texto curto + até 3 fotos, opcional).

**Aba Financeiro do cliente** — vendas, o que foi pago, o que está em aberto, parcelas com data de vencimento.

### Tela 4 — FINANCEIRO

Duas abas.

**Lançamentos** — tabela de todos os pagamentos, filtro por período, forma e status.
Novo lançamento: `cliente` · `data` · `valor` · `forma de pagamento` (`pix` · `dinheiro` · `débito` · `crédito à vista` · `crédito parcelado` · `link` · `boleto`) · `nº de parcelas` · `procedimento/venda vinculada` · `valor de tabela` · `desconto aplicado` · `observação`.
Se parcelado, o sistema **gera automaticamente as parcelas** com vencimentos mensais, cada uma com status `previsto` · `recebido` · `atrasado`.

**A receber** — todas as parcelas em aberto ordenadas por vencimento, com destaque para atrasadas. Botão "marcar como recebido" em um clique.

Regras:
- Toda venda pode ter N pagamentos; todo pagamento pertence a uma venda.
- **Avaliação gratuita e retorno são registrados com valor R$ 0 e marcados explicitamente como `gratuito`** — nunca somam em receita.
- Valores em BRL, vírgula decimal na exibição, armazenados como decimal (nunca float).

### Tela 5 — PAINEL

Cartões grandes, sem gráfico enfeite. Filtro de período no topo (mês atual por padrão).

| Bloco | Indicadores |
|---|---|
| **Caixa** | Recebido no período · A receber (em aberto) · Atrasado · Ticket **mediano** pago (nunca média) |
| **Agenda** | Agendamentos no período · **Taxa de comparecimento** (compareceu ÷ agendados) · Taxa de no-show · Cancelamentos por motivo |
| **Conversão** | **⭐ Avaliação → procedimento pago** (clientes que pagaram depois de uma avaliação ÷ clientes com avaliação realizada) — indicador principal da clínica |
| **Entrega** | Protocolos em andamento · Taxa de conclusão de protocolo · Clientes com sessão atrasada |
| **Base** | Taxa de recompra (2+ compras pagas ÷ pagantes) · Clientes sem retorno há mais de 90 dias · Receita por procedimento (ranking) |

Linhas de base atuais para referência do produto: comparecimento = desconhecido; avaliação→pago = 30,4% (piso); ticket mediano = R$ 707,90; recompra = 35,8%.

---

## 5. Modelo de dados (mínimo viável)

```
cliente        (id, nome, telefone_digitos, cpf, nascimento, cidade, origem,
                consentimento_lgpd, criado_em)
procedimento   (id, codigo_canonico, nome_exibicao, familia, duracao_min,
                valor_tabela, sessoes_padrao, e_avaliacao_gratuita)
agendamento    (id, cliente_id, procedimento_id, profissional_id, data_hora,
                data_marcacao, tipo, status, motivo_cancelamento,
                id_agendamento_origem, protocolo_id, sessao_n, observacao)
atendimento    (id, agendamento_id, cliente_id, data, profissional_id,
                evolucao, fotos[])
protocolo      (id, cliente_id, procedimento_id, total_sessoes,
                sessoes_realizadas, status, iniciado_em, concluido_em)
venda          (id, cliente_id, data, valor_total, desconto, e_gratuito, itens[])
item_venda     (id, venda_id, procedimento_id, quantidade, valor)
pagamento      (id, venda_id, valor, forma, parcela_n, total_parcelas,
                vencimento, data_recebimento, status)
anamnese       (id, cliente_id, versao, respostas_json, contraindicacao,
                profissional_id, criado_em)
usuario        (id, nome, email, senha_hash, papel)
```

**Regras não negociáveis:**
1. `telefone_digitos` — só dígitos, sem máscara, indexado. É a chave de cruzamento com o CRM. Comparação por **últimos 8 dígitos**.
2. `procedimento` é **cadastro fechado com código canônico**. Nunca texto livre no agendamento ou na venda.
3. Nada é deletado. Cancelamento e remarcação são status, não exclusão.
4. Toda mudança de status de agendamento e todo pagamento gravam autor e timestamp.
5. Dinheiro em `decimal(10,2)`. Nunca float.

---

## 6. Interoperabilidade com o CRM

Sem integração automática na v1. Apenas:
- **Importação inicial** por CSV: clientes (nome, telefone, cpf, origem) e histórico de atendimentos.
- **Exportação** por CSV de agendamentos, vendas e pagamentos, com `telefone_digitos` em toda linha — para que qualquer cruzamento futuro com o CRM funcione sem retrabalho.
- Campo opcional `id_crm` no cliente, preenchido na importação.

---

## 7. Requisitos não funcionais

- Web app responsivo. **A Agenda precisa funcionar bem em tablet** (é a tela da recepção).
- Sugestão de stack: React + TypeScript, backend Node ou Python, Postgres. Deploy simples, instância única.
- Autenticação por e-mail/senha, sessão de 12h.
- Idioma: pt-BR. Datas `dd/mm/aaaa`. Moeda BRL com vírgula decimal.
- Backup diário automático do banco.
- Dados de saúde: acesso restrito por papel; anamnese visível apenas a profissional e gestão.
- Desempenho alvo: qualquer tela carrega em menos de 2s com 10.000 clientes e 50.000 agendamentos.

---

## 8. Critérios de aceite

1. Um agendamento é criado, confirmado e marcado como `compareceu` em **3 cliques ou menos** cada.
2. Ao final de um dia de uso real, o Painel mostra a taxa de comparecimento sem nenhuma planilha.
3. Uma venda parcelada em 6x gera 6 parcelas com vencimento correto, e a aba "A receber" mostra as 6.
4. A ficha de um cliente com 4 atendimentos mostra os 4 em ordem, com valores e status de pagamento.
5. Uma anamnese com contraindicação marcada exibe alerta em toda a ficha do cliente.
6. Exportar CSV de vendas e somar a coluna de valor bate exatamente com o "Recebido" do Painel no mesmo período.
7. Nenhum procedimento pode ser gravado como texto livre.

---

## 9. Ordem de construção sugerida

1. Cadastro de clientes + procedimentos canônicos + login (base de tudo)
2. **Agenda com status** — é o dado que hoje não existe em lugar nenhum, e é o de maior valor isolado
3. Financeiro (lançamentos e parcelas)
4. Ficha do cliente (histórico + anamnese)
5. Painel

Cada etapa é entregável e utilizável sozinha.
