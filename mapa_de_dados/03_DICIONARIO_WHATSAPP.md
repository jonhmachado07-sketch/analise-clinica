# 03 — Dicionário do corpus de WhatsApp

**Pasta:** `exportacao_whatsapp_clientes/`
**38 arquivos `.zip`** → **35 conversas únicas** (3 duplicatas) + 1 pasta já descompactada
**~4.480 mensagens** analisadas · **16/03/2023 → 07/08/2026**

---

## 1. Formato e parsing

Cada zip contém um `_chat.txt` em UTF-8. Uma mensagem por linha:

```
[11/05/2025, 18:32:24] ~Débora Schultes: Olá Mayara! Tenho interesse em mais informações sobre a Crio Turbo.
```

**Regex de referência:**
```
\[(\d{2})/(\d{2})/(\d{4}), (\d{2}):(\d{2}):(\d{2})\] ([^:]{1,80}): ?(.*)
```

**Quem é quem:**
- **Clínica** — remetente contém `Estética Mayara Ribeiro especialista em Harmonização Corporal`
- **Cliente** — qualquer outro remetente, tipicamente prefixado com `~` (ex.: `~Débora Schultes`)

**Descartar:** a primeira linha de cada conversa é o aviso de criptografia de ponta a ponta, não é mensagem.

**Caracteres invisíveis:** as linhas de mídia começam com o marcador U+200E (LEFT-TO-RIGHT MARK). Os nomes de arquivo usam **hífen tipográfico U+2011**, não hífen comum — comparações literais de string falham. Normalizar antes.

---

## 2. Inventário conversa a conversa

`Msgs` = mensagens · `Mídia` = referências a áudio/imagem/documento ocultos · `CRM` = match por telefone no Kommo.

| Conversa | Msgs | Mídia | Período | Match no CRM | Origem |
|---|---:|---:|---|---|---|
| +55 27 99517‑4885 | 557 | 49 | 27/03/2024 – 06/08/2026 | Jackeline Prati | *(vazia)* |
| +55 31 99145‑9604 | 431 | 87 | 23/06/2026 – 05/08/2026 | Fernanda de Oliveira Marques | META ADS |
| Mara Cristina Cliente Serra | 381 | 37 | 23/09/2024 – 31/07/2026 | — *(sem telefone no nome)* | — |
| +55 27 99740‑3722 | 349 | 64 | 29/01/2026 – 06/08/2026 | Eline Camilo | META ADS |
| Danielly d'Lucas | 291 | 50 | 17/07/2025 – 06/08/2026 | — *(sem telefone)* | — |
| **+55 27 99507‑9909** | 254 | 1 | 16/01/2026 – 08/05/2026 | Jhulia | META ADS |
| +55 27 99629‑4757 | 230 | 19 | 08/07/2026 – 06/08/2026 | Flávia Pirchiner | META ADS |
| +55 27 99654‑3844 | 161 | 16 | 11/05/2025 – 31/07/2026 | Débora | META ADS |
| +55 27 99778‑0442 | 149 | 45 | 19/06/2026 – 03/08/2026 | Juracilda A. P. Domingos | META ADS |
| +55 27 99229‑5330 | 127 | 11 | 30/04/2026 – 03/08/2026 | Douriane | REATIVAÇÕES |
| +55 27 99850‑0393 | 124 | 4 | 16/03/2023 – 05/08/2026 | *(sem match)* | — |
| +55 27 99604‑1377 | 122 | 12 | 11/04/2025 – 06/08/2026 | Vidal Ludimylla | REATIVAÇÕES |
| Ana Flavia | 113 | 10 | 24/04/2025 – 02/06/2026 | — *(sem telefone)* | — |
| Valdirene Cavatti Cliente Serra | 98 | 8 | 22/04/2024 – 04/08/2026 | — *(sem telefone)* | — |
| +55 27 99644‑3593 | 95 | 11 | 29/07/2026 – 03/08/2026 | Daiane | META ADS |
| +55 27 99927‑7849 | 94 | 23 | 24/11/2025 – 31/07/2026 | Luciane | META ADS |
| +55 27 99234‑7187 | 93 | 9 | 09/07/2026 – 07/08/2026 | Vanessa Gonçalves | META ADS |
| +55 27 99760‑3192 | 93 | 14 | 16/07/2026 – 06/08/2026 | Mauriceia | *(vazia)* |
| +55 27 99795‑6907 | 85 | 22 | 02/12/2024 – 06/08/2026 | Nitsa Lima | REATIVAÇÕES |
| +55 27 99700‑9053 | 79 | 26 | 29/07/2026 – 04/08/2026 | Liliani | META ADS |
| +55 27 99876‑9464 | 79 | 14 | 05/12/2025 – 05/08/2026 | Eliane Buenos Aires | META ADS |
| +55 27 98896‑3293 | 76 | 9 | 24/05/2026 – 06/08/2026 | Ketlym Marcelly | *(vazia)* |
| +55 27 99653‑4153 | 58 | 7 | 05/02/2025 – 06/08/2026 | Larissa | *(vazia)* |
| +55 27 99971‑8517 | 40 | 6 | 29/07/2026 – 03/08/2026 | Fernanda | META ADS |
| +55 27 99614‑5258 | 37 | 4 | 04/08/2026 – 06/08/2026 | Tâmara | *(vazia)* |
| +55 27 99929‑7642 | 36 | 0 | 28/07/2026 – 03/08/2026 | Carol | *(vazia)* |
| +55 27 99660‑3761 | 34 | 0 | 11/11/2024 – 03/10/2025 | *(sem match)* | — |
| +55 27 99808‑4186 | 31 | 6 | 03/08/2026 – 07/08/2026 | Mary | META ADS |
| +55 27 99577‑7766 | 31 | 1 | 24/07/2026 – 06/08/2026 | Ingrid Deus | *(vazia)* |
| +55 27 98173‑5888 | 31 | 6 | 05/07/2025 – 07/08/2026 | *(sem nome)* | META ADS |
| +55 27 99904‑7991 | 30 | 3 | 18/06/2026 – 04/08/2026 | Jaqueline | META ADS |
| +55 27 99914‑1094 | 29 | 7 | 31/07/2026 – 04/08/2026 | Mari | META ADS |
| +55 27 99714‑7323 | 28 | 1 | 23/07/2026 – 31/07/2026 | Poliane | *(vazia)* |
| +55 27 99699‑8019 | 28 | 5 | 20/07/2026 – 31/07/2026 | Márcia | *(vazia)* |
| +55 27 99663‑7336 | 21 | 4 | 07/10/2025 – 13/10/2025 | Luciana Vidal | *(vazia)* |

**Duplicatas a ignorar** — mesmo conteúdo, sufixo ` (1)`:
`+55 27 99507‑9909 (1)` · `+55 27 99760‑3192 (1)` · `+55 27 99700‑9053 (1)`

Existe também a pasta descompactada `WhatsApp Chat - +55 27 99654‑3844/` — mesmo conteúdo do zip homônimo.

**Cobertura:** 31 das 35 conversas trazem o telefone no nome do arquivo; **29 casam com um contato no CRM (83%)**. As 4 nomeadas por pessoa (`Ana Flavia`, `Danielly d'Lucas`, `Mara Cristina`, `Valdirene Cavatti`) só podem ser ligadas por nome — e são justamente algumas das conversas mais longas.

---

## 3. ⚠️ A amostra e o que ela não representa

35 conversas contra **6.374 contatos no CRM: 0,55% da base.**

E a amostra **não é aleatória** — está enviesada para conversas longas (mediana de 85 mensagens; a base real deve ter muita conversa de 2 ou 3 trocas que morreu no primeiro contato). **26 das 35 conversas se estendem até agosto de 2026**, ou seja, são conversas ativas ou recentes.

**O que isto permite:** caracterizar *como* a clínica conversa — script, ritmo, objeções, latência.
**O que isto NÃO permite:** medir taxas. Nenhum percentual calculado sobre estas 35 conversas deve ser extrapolado para a base.

Ver §7 para a especificação de uma amostra que sustente medição.

---

## 4. Padrões observáveis no texto

### 4.1 Volume e direção

| Métrica | Valor |
|---|---:|
| Mensagens da clínica | 2.364 (52,9%) |
| Mensagens do cliente | 2.108 (47,1%) |
| Conversas **iniciadas pelo cliente** | 33 de 35 |
| Conversas em que a **clínica fala por último** | 26 de 35 |

**A clínica fala mais e fala por último.** As conversas não terminam em decisão — terminam em silêncio do cliente depois de mensagem da clínica. Em 26 dos 35 casos o último registro é a clínica falando sozinha. Esse é o formato típico do abandono nesta operação: não há "não", há ausência de resposta.

### 4.2 Horários

| Faixa | Mensagens |
|---|---|
| 00h–07h | 115 (2,6%) |
| **08h–12h** | 1.515 (33,9%) |
| **13h–17h** | 2.128 (47,6%) |
| 18h–20h | 579 (12,9%) |
| 21h–23h | 135 (3,0%) |

Picos em **14h (490)** e **16h (492)**; vale claro no almoço às 12h. **81,5% das mensagens acontecem entre 8h e 17h** — a operação é de horário comercial e o cliente acompanha esse ritmo.

**Por dia da semana:** quarta 985 · segunda 856 · quinta 805 · sexta 734 · terça 728 · **sábado 233 · domingo 131**. Fim de semana é 8,1% do volume.

**Uso possível:** dimensionar equipe de atendimento e definir janela de disparo de reativação. **Uso impossível hoje:** saber se o lead que chega às 21h converte pior que o das 14h — isso exige o join com resultado, que só existe para os 29 contatos com match.

### 4.3 Latência de resposta

| Quem responde | n | Mediana | p75 | p90 |
|---|---:|---:|---:|---:|
| **Clínica** | 1.066 | **9,6 min** | 82,9 min | **701,4 min** (11,7h) |
| **Cliente** | 998 | 3,4 min | 25,8 min | 174,0 min (2,9h) |

Leitura: a clínica responde rápido na mediana, mas **a cauda é longa — em 10% dos casos demora quase 12 horas**, o que na prática significa "só no dia seguinte". O cliente é consistentemente **3× mais rápido** que a clínica.

Esse descasamento é o candidato mais forte a gargalo mensurável do atendimento — e é testável assim que houver dados de agendamento: leads cuja primeira resposta demorou mais de X converteram menos?

### 4.4 Script da clínica

A operação segue um roteiro identificável, reproduzido com pouca variação:

| Momento | Frase observada | Ocorrências |
|---|---|---|
| Autoresposta de entrada | "Olá! Diga como podemos ajudar você." | 11 |
| Mensagem automática do anúncio *(lado do cliente)* | "Tenho interesse em mais informações sobre a *[produto]*" | 11 |
| Boas-vindas | "Bem-vinda à nossa clínica. 🥰 Me chamo Mayara Ribeiro. Já já te respondo!" | 2 |
| Qualificação 1 — motivação | "antes da gente começar, me conta o que está te motivando a buscar por *[produto]* e qual sua principal expectativa?" | 1 |
| Qualificação 2 — histórico | "Você já realizou algum procedimento para redução de peso e medidas ou tratamento de flacidez anteriormente?" | **21** |
| Qualificação 3 — foto | "Você teria fotos atualizadas da região que pretende tratar?" | 8 |
| **Reativação** | "Tivemos uma primeira tentativa de contato, mas acredito que esteja na correria... Seu interesse ainda é real e atual?" | 4 |
| Retomada | "Bom dia, tudo bem?" | 6 |

**Observações:**
- A mensagem "Tenho interesse em mais informações sobre a Crio Turbo" é gerada pelo próprio anúncio do Meta. **É o único ponto do corpus que carrega o produto anunciado** — e portanto o vestígio mais próximo de atribuição por campanha que existe hoje. Aparece em 11 conversas. Ver `04_MAPA_DE_JUNCOES.md` §5.
- A qualificação por histórico (21 ocorrências) é aplicada de forma consistente; a qualificação por motivação, quase nunca por escrito — provavelmente migrou para o áudio.
- Existe um **script formal de reativação** com cadência própria, disparado meses depois. No caso da Débora, a primeira tentativa foi em 13/05/2025 e a retomada em **03/10/2025** — quase 5 meses.

### 4.5 Assuntos e objeções

Frequência de termos no corpus completo:

| Tema | Termos e ocorrências |
|---|---|
| **Agendamento** | `horário` 123 · `agendamento` 66 · `agendar` 55 · `avaliação` 50 · `marcar` 20 · `remarcar` 10 · `cancelar` 5 |
| **Tempo** | `hoje` 98 · `amanhã` 63 |
| **Preço e pagamento** | `valor` 66 · `quanto` 50 · `cartão` 20 · `parcel` 9 · `pix` 7 · `promoção` 6 · `desconto` 1 · `custa` 2 · `preço` 1 |
| **Resultado e segurança** | `resultado` 64 · `dor` 22 · `amamenta` 3 · `contraindicação` 1 |
| **Hesitação** | `pensar` 5 |

**Produtos citados:** Endolaser 228 · Criolipólise 112 · Drenagem 30 · Crio Turbo 28 · Botox 11 · Preenchimento 8 · Enzimas 6 · Bioestimulador 2. **Morosil, Glúteo Maxx e Microvasos: zero menções** — apesar de a Cápsula Morosil ser o item de maior receita atribuída (R$ 240.049,90). São vendas presenciais, invisíveis ao corpus de conversa.

⚠️ **Leia estas contagens com desconfiança.** `preço` aparece 1 vez e `valor` 66 — não porque preço não seja discutido, mas porque **a discussão de preço acontece em áudio**. O corpus mede o que é *escrito*, e o que é escrito é predominantemente logística (horário, dia, confirmação). A conversa comercial de verdade está fora dele.

### Exemplo de objeção completa preservada em texto

Da conversa `+55 27 99654‑3844` (Débora, META ADS, Crio Turbo), 13/05/2025 — o padrão de objeção clínica:

> Cliente: "Estou amamentando, tem alguma contra indicação?"
> Clínica: "A crio não, somente os injetáveis que não são indicados"
> Cliente: "Fiquei sabendo que não posso fazer esse procedimento"
> Clínica: "E explicaram pq? Me conta ✨"
> Cliente: "a enfermeira do posto de saúde falou que pode atrapalhar a produção do leite"
> Clínica: "E o que ela explicou que acontece pra isso ocorrer?"
> Cliente: "Só falou isso mesmo. Eu vou esperar o desmame. Acho mais seguro"
> *[áudio ocultado]* ← **a resposta da clínica à objeção final está perdida**

Este trecho é o retrato do corpus inteiro: a técnica de contorno (devolver a pergunta em vez de rebater) é visível, mas **o argumento decisivo está no áudio**, e a conversa é retomada só 5 meses depois pelo script de reativação.

---

## 5. Quem atende: identidade única, várias pessoas

Todas as mensagens da clínica saem sob o mesmo remetente — `Estética Mayara Ribeiro especialista em Harmonização Corporal` — mas **são pessoas diferentes**, que se identificam no corpo do texto:

> "Ei Débora, boa tarde. **\*Vanessa\*, aqui.**"
> "Eii Débora, como você está hoje? 🥰 **Mayara Ribeiro aqui.**"

Nomes identificados na assinatura: **Mayara Ribeiro, Vanessa, Bandeira, Lorrainy, Kátia**.

**Consequências:**
1. Não há campo estruturado de atendente — só texto livre, e nem toda mensagem assina.
2. Combinado com o `Responsável` constante em `Vendas Detalhadas` (§3 do doc 02) e o `Usuário responsável` quase monocolor no CRM, o resultado é que **nenhuma análise de desempenho por atendente é possível em nenhuma das três fontes**.
3. Do lado do cliente, o efeito é de continuidade — ele conversa sempre com "a clínica". Do lado da gestão, é um ponto cego total.

---

## 6. ⚠️ O que se perdeu: a mídia

**591 referências a mídia oculta** em 33 das 35 conversas:

| Tipo | Ocorrências |
|---|---:|
| **`áudio ocultado`** | **287** |
| `imagem ocultada` | 234 |
| `documento omitido` (webp e PDF) | 39 |
| `figurinha omitida` | 17 |
| `vídeo omitido` | 11 |
| `Cartão do contato omitido` | 3 |

**O que estava nesses arquivos:**
- **287 áudios** — a apresentação do procedimento, a explicação técnica, a apresentação de preço, o contorno de objeção e o fechamento. É onde a venda acontece nesta operação.
- **234 imagens** — as fotos "da região que pretende tratar" que a clínica pede na qualificação (o script aparece 8 vezes), tabelas de preço, resultados antes/depois.

**Por que isto enviesa tudo:** o corpus disponível é o *resíduo textual* de uma operação que vende por áudio. Sobrou a logística — horário, dia, confirmação — e sumiu o argumento. Qualquer conclusão sobre "como a clínica vende", "quais objeções derrubam a venda" ou "como o preço é apresentado" tirada só do texto será **sistematicamente errada**, não apenas incompleta.

### ✅ A boa notícia: exportar com mídia é possível e já foi feito

A conversa **`+55 27 99507‑9909`** veio com **42 arquivos**: 13 áudios `.opus`, 16 fotos `.jpg`, 2 vídeos `.mp4`, 1 `.png`, 9 `.webp`. Os nomes trazem tipo e timestamp:

```
00000004-AUDIO-2026-01-16-11-30-29.opus
00000019-PHOTO-2026-01-16-16-40-20.jpg
```

Ou seja: **não é limitação do WhatsApp — foi escolha na hora de exportar.** As outras 34 conversas foram exportadas em "Sem mídia". Essa única conversa é a prova de conceito de que o pipeline de transcrição é viável.

---

## 7. O que pedir na re-exportação

### 7.1 Sempre exportar **com mídia**
Opção "Anexar mídia" no WhatsApp. Aumenta o tamanho (a conversa com mídia tem 32 MB contra ~5 KB sem), mas é a diferença entre ter e não ter o dado.

### 7.2 Amostra estratificada
Para permitir **medição** e não só caracterização, a amostra precisa cobrir os quatro desfechos, e não só as conversas longas:

| Estrato | Definição | Sugestão |
|---|---|---|
| **Converteu** | contato → venda paga registrada | 30 conversas |
| **Compareceu e não pagou** | fez avaliação gratuita e parou | 30 conversas |
| **Sumiu no meio** | respondeu e parou antes de agendar | 40 conversas |
| **Nunca respondeu** | clínica falou, cliente nunca voltou | 20 conversas |

**200 conversas** (3% da base) dão sustentação estatística para taxas. As 35 atuais não dão.

Selecionar os telefones cruzando o CRM com `Vendas Detalhadas` — a estratificação pode ser montada com os dados que já temos (ver `04_MAPA_DE_JUNCOES.md`).

### 7.3 Preferir o export do CRM ao export do celular
O Kommo está conectado ao WhatsApp. Se ele expuser o histórico de mensagens via export ou API, isso resolve de uma vez os três problemas: cobertura total em vez de amostra, vínculo nativo com o contato (dispensando match por telefone), e carimbo de atendente real. **Verificar essa possibilidade antes de re-exportar manualmente 200 conversas do celular.**

### 7.4 Pipeline de transcrição — fase posterior
Fora do escopo deste mapa, mas já definido para quando os áudios chegarem:
1. Extrair `.opus` dos zips, associando cada arquivo à sua linha no `_chat.txt` pelo timestamp do nome.
2. Transcrever com reconhecimento de fala em português.
3. Reinserir a transcrição na posição original da conversa, marcada como `[TRANSCRIÇÃO]`.
4. Só então rodar a análise de argumentação, objeção e apresentação de preço.

O passo 1 já é possível hoje na conversa `+55 27 99507‑9909` — serve de piloto para validar o pipeline antes da re-exportação em massa.
