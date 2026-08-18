# 00 — Visão Geral: o mapa do território

> Documento-raiz do mapa de interpretação de dados da clínica.
> Leia este primeiro. Os demais aprofundam cada fonte.
> Versão 1 — baseada nas exportações de 07/08/2026 e 11/08/2026.

---

## 1. O fluxo real do cliente e onde ele deixa rastro

```
   ┌───────────┐   ┌────────────┐   ┌────────────┐   ┌─────────────┐   ┌────────────┐   ┌──────────┐
   │ 1. ANÚNCIO│──▶│ 2. CONTATO │──▶│ 3. CONVERSA│──▶│4. AGENDAMENTO│──▶│5.ATENDIMENTO│──▶│6. PÓS-   │
   │  Meta Ads │   │   no CRM   │   │  WhatsApp  │   │              │   │/ PROCEDIMENTO│   │  VENDA   │
   └───────────┘   └────────────┘   └────────────┘   └─────────────┘   └────────────┘   └──────────┘
        │                │                │                 │                │               │
   Meta Ads         Kommo CSV       38 zips de         ██ NADA ██      Vendas Detalhadas   ██ NADA ██
   (3 abas          + aba           conversa                            (aba da xlsx)
    agregadas)      Contatos CRM
        │                │                │                 │                │               │
    AGREGADO         COMPLETO          AMOSTRA           CEGO            COMPLETO           CEGO
   (sem lead)       (sem funil)      (0,6% da base)                  (até 25/12/2025)
```

### Tabela etapa × fonte × qualidade

| # | Etapa do cliente | Fonte que registra | Grão do registro | Cobertura | Status |
|---|---|---|---|---|---|
| 1 | Anúncio / mídia paga | `Meta Ads — Produto / Faixa Etária / Campanhas` | campanha e faixa etária | 55 campanhas, R$ 31.981,35 vitalícios | **Agregado** — não há vínculo anúncio↔pessoa |
| 2 | Entrada como contato | `kommo_export_contacts_and_companies` + aba `Contatos CRM` | um contato | 6.374 contatos, 01/04/2025 → 07/08/2026 | **Parcial** — sem etapa de funil |
| 3 | Conversa/qualificação | pasta `exportacao_whatsapp_clientes` | uma mensagem | 34 conversas úteis, ~4.480 mensagens | **Amostra** — e sem o conteúdo dos áudios |
| 4 | Agendamento | — | — | — | **CEGO** |
| 5 | Atendimento/procedimento | aba `Vendas Detalhadas` | um atendimento | 1.423 linhas, 09/07/2024 → 25/12/2025 | **Completo até 25/12/2025** |
| 6 | Pós-venda / sucesso | — (só indícios em conversas) | — | — | **CEGO** |

O cliente atravessa seis etapas. **Duas não têm registro nenhum** (agendamento e pós-venda), uma é agregada demais para decidir verba (anúncio), e uma existe mas foi exportada sem o que interessa (funil).

---

## 2. As cinco maiores lacunas, por impacto na decisão

| # | Lacuna | Por que dói |
|---|---|---|
| 1 | **Sem etapa de funil no CRM** — o export é de *contatos*, não de *leads* | É exatamente o dado necessário para reestruturar o funil. Hoje não se sabe onde o lead trava, quanto tempo fica em cada etapa, nem por que se perde. Toda conversão é reconstruída *a posteriori* cruzando contato com venda. |
| 2 | **Sem atribuição por campanha no nível do lead** | R$ 31.981,35 investidos e 55 campanhas, mas a receita só pode ser lida por canal e por produto inferido do nome da campanha. Não dá para dizer qual anúncio trouxe qual cliente — logo, não dá para cortar verba com segurança. |
| 3 | **Agendamento e comparecimento não existem em lugar nenhum** | Sem no-show, remarcação ou cancelamento, não se separa "não vendeu" de "vendeu e não apareceu". O gargalo mais caro da operação é justamente o invisível. |
| 4 | **Janela de vendas fecha em 25/12/2025** | 2.091 contatos criados depois disso não podem ser atribuídos a receita. *Será resolvida com os dados do novo sistema* — ver §5. |
| 5 | **Todo o conteúdo de áudio e imagem do WhatsApp está oculto** | 287 áudios e 234 imagens referenciados e perdidos. A venda acontece no áudio: preço, objeção e fechamento estão fora do corpus. Qualquer conclusão sobre argumentação é enviesada. |

---

## 3. As três fontes, em números

| Fonte | Arquivo | Escala | Janela |
|---|---|---|---|
| CRM (Kommo) | `exportacao_funis_crm/kommo_export_contacts_and_companies_2026-08-07.csv` | 6.374 contatos + 4 empresas · 37 colunas | 01/04/2025 → 07/08/2026 |
| Agendamento/vendas | `exportacao_sistemas_agendamento/Base Unificada - Clinica Expert.xlsx` | 8 abas · 992 clientes · 1.423 atendimentos · 6.375 contatos · 55 campanhas | vendas 09/07/2024 → 25/12/2025 |
| WhatsApp | `exportacao_whatsapp_clientes/` | 38 zips (34 únicos) · ~4.480 mensagens | 16/03/2023 → 07/08/2026 |

**A xlsx não é fonte bruta.** É um produto derivado de um trabalho anterior de consolidação, que já cruzou cadastro da clínica + vendas + CRM + Meta Ads, e que documenta na aba `Auditoria` a chave de match usada e as limitações conhecidas. Este mapa **absorve e estende** esse trabalho — não o refaz. Ver [`02_DICIONARIO_BASE_UNIFICADA.md`](02_DICIONARIO_BASE_UNIFICADA.md).

---

## 4. Convenções para qualquer análise futura

**Datas.** Todas as fontes usam `dd/mm/aaaa`. No CRM o carimbo é `dd.mm.aaaa hh:mm:ss` (ponto, não barra). No WhatsApp é `[dd/mm/aaaa, hh:mm:ss]`. Nunca interpretar como `mm/dd`.

**Números.** ⚠️ **Armadilha confirmada:** na aba `Vendas Detalhadas` os valores são **texto com vírgula decimal** (`2499,9`). Parsear com cultura `pt-BR`. Lendo como invariante (ponto decimal), `2499,9` vira `24999` e a soma total sai **R$ 1.823.364,00** em vez de **R$ 805.879,35** — erro de 2,26×. Toda análise deve começar batendo a soma contra R$ 805.879,35.

**Telefone.** Cada fonte usa um formato diferente: CRM `'+5527992387855` (com apóstrofo à frente), cadastro `+55 (27) 99920-8977`, WhatsApp `+55 27 99654‑3844` (com hífen tipográfico U+2011 no nome do arquivo). Normalizar sempre para dígitos e comparar pelos **8 últimos**. Ver [`04_MAPA_DE_JUNCOES.md`](04_MAPA_DE_JUNCOES.md).

**Janelas de referência.**
- Janela comparável para conversão: contatos criados **até 25/12/2025** → 4.283 contatos.
- Janela de receita atribuída: **abr–dez/2025**.
- Verba de mídia: **vitalícia, 07/07/2023 → 07/08/2026** — não é comparável à receita de 9 meses sem ressalva. O ROAS de 8,59 na `Auditoria` é deliberadamente conservador.

**"Venda" ≠ "atendimento pago".** 530 das 1.423 linhas de `Vendas Detalhadas` (**37,2%**) têm valor R$ 0 — são avaliações, reavaliações e retornos pós-procedimento. Ver §5 de [`02_DICIONARIO_BASE_UNIFICADA.md`](02_DICIONARIO_BASE_UNIFICADA.md). Contar 1.423 como "vendas" superestima o volume comercial em mais de um terço.

**Canal ≠ aquisição.** `Reativação` (1.104 contatos) e `Base de Clientes` (16) são trabalho sobre a base existente, não aquisição. Somar tudo como canal infla o topo do funil e distorce o CAC.

---

## 5. Ponto de entrada dos dados do novo sistema

Os dados do novo sistema de agendamento chegarão depois e devem **enriquecer este mapa sem reescrevê-lo**. Eles se encaixam em três pontos:

1. **Fecham a etapa 4 (agendamento)** — hoje totalmente cega. É a maior adição isolada de valor.
2. **Estendem a etapa 5 para além de 25/12/2025** — desbloqueando os 2.091 contatos hoje inatribuíveis.
3. **Podem abrir a etapa 6 (pós-venda)**, se trouxerem retorno programado e resultado do procedimento.

A especificação do que pedir está em §4 de [`05_LACUNAS_E_PERGUNTAS.md`](05_LACUNAS_E_PERGUNTAS.md). Quando chegarem, revisar: este documento (§1 e §2), o dicionário da base unificada, e o catálogo de perguntas respondíveis.

---

## 6. Índice do mapa

| Documento | O que contém |
|---|---|
| [`01_DICIONARIO_CRM.md`](01_DICIONARIO_CRM.md) | As 37 colunas do Kommo, taxa de preenchimento real, distribuições, e o que o export não traz |
| [`02_DICIONARIO_BASE_UNIFICADA.md`](02_DICIONARIO_BASE_UNIFICADA.md) | As 8 abas da xlsx, grão de cada uma, o padrão `V1..V17`, e a auditoria herdada |
| [`03_DICIONARIO_WHATSAPP.md`](03_DICIONARIO_WHATSAPP.md) | Formato do corpus, inventário conversa a conversa, padrões de horário/latência/script, e o que se perdeu nos áudios |
| [`04_MAPA_DE_JUNCOES.md`](04_MAPA_DE_JUNCOES.md) | Como cruzar as fontes, taxa de sucesso real de cada junção, riscos de match |
| [`05_LACUNAS_E_PERGUNTAS.md`](05_LACUNAS_E_PERGUNTAS.md) | O que dá para responder hoje (com nível de confiança) e a matriz priorizada de lacunas |
