---
name: pesquisa
description: "Pesquisa profunda em funil multi-nível com fontes verificadas. Use SEMPRE que o usuário disser 'pesquisa', 'pesquisar', 'investiga', 'me ajuda a entender X', 'quero saber sobre Y' ou invocar /pesquisa — esse é o gatilho principal e mais óbvio. Também use proativamente para: comparativos com dados reais (X vs Y, framework A vs B, produto/carro/plano), decisões com stakes (migração de stack, fornecedor, plataforma), validação contra fontes (estudos científicos, benchmarks, segunda opinião médica), análise de mercado/competitiva, deep dive em estado da arte, TCO, impacto de mudanças regulatórias, ou literatura médica/farmacológica (interações, efeitos, validação de diagnóstico) — mesmo quando o user já consultou profissional. NÃO use para perguntas factuais rápidas, debug de código, operações de arquivo, ou referência a invocação anterior. Flags: -f (auto), -a (anônimo)."
---

# Pesquisa em Funil v3

> **v3.3 (2026-06-24):** motor migrado de Perplexity → **Exa** (`web_search_advanced_exa` + `web_fetch_exa`; suporta conector simples, avançado ou fallback nativo). **Calibrado por benchmark de 5 casos:** query-phrasing é o **padrão** do Nível 3 — a busca neural já entrega ~10/10 Tier A com uma frase boa. Filtro nativo (`includeDomains`) é **exceção**, só pra fonte oficial/primária que o ranking não acha (jurídico/regulatório). `category: "company"` e `category: "news"+data` **pioram** e devem ser evitados (ver Nível 3 Passo 1).

> **v3.4 (Titan):** dois pontos de segunda opinião via **Codex (GPT)** — o mesmo mecanismo de
> confronto que o `/planejar` usa (`_shared/confronto-codex.md`). Não é o Phase Gate (aquele
> confere evidência); é um advogado do diabo questionando a decisão: o enquadramento faz sentido
> (fim do Nível 2) e a conclusão resolve o problema (fim do Nível 3)? Ver `references/codex-revisor.md`.

Evolução do `/pesquisa` (v2) com 3 técnicas roubadas de skills do marketplace:

| Técnica | Origem | O que muda |
|---------|--------|------------|
| CRAAP scoring | claim-investigation | Score 0-100 por critério, não só tier |
| Phase Gate por fatos-chave | claim-investigation | ≥2 fontes independentes por fato central |
| Domain filters | Exa `web_search_advanced_exa` | `category` + `includeDomains` + data nativos (PubMed/arXiv/gov.br) |

## O Funil v3

```
Nível 1: Varredura (web_search_advanced_exa paralelo)
    │ Apresentar → usuário aprova direção (HITL)
    ▼
Nível 2: Análise (Claude raciocina) + identificar fatos-chave + sub-tópicos
    │ Apresentar + listar sub-tópicos + fatos-chave → usuário escolhe (HITL)
    ▼
Nível 3: Deep Dive PARALELO (N × web_search_advanced_exa + web_fetch_exa)
    │ Phase Gate v3: sub-perguntas respondidas? + fatos-chave em ≥2 fontes? + CRAAP?
    │ Se não → gap filling focado
    ▼
Relatório final → salvo como ~/pesquisas/[tema]-[data].md
```

**Regra inviolável:** human-in-the-loop entre cada nível. Não pular sem aprovação.

## ★ v3.1 — defesa em profundidade pós-incidente 2026-04-29

Esta skill foi auditada após dogfood que revelou `/pesquisa` rodando "internamente" (modelo se autovigia), gerando relatórios com seções obrigatórias ausentes e CRAAP inflacionado. Mudanças:

- **Phase Gate via subagent independente** (Passo 5): não é mais `executar internamente`, é `Agent({subagent_type: Explore, ...})` produzindo `verification_report.json`
- **CRAAP rubric calibrada** com 3 exemplos por Tier (Passo 4) — sem isso, scores convergem pra 88-95
- **Definição programática de "fonte independente"**: domínios distintos + não-duplicação de paper primário
- **PostToolUse hook validador** em `~/.claude/skills/pesquisa/scripts/validate-report.py` — bloqueia Write em `~/pesquisas/*.md` se relatório não tiver todas seções obrigatórias OU se >50% fatos têm <2 fontes

### Bloco contrastive (good vs bad fluxo)

**❌ Execução RUIM (incidente 2026-04-29):**
```
1. Spawn 5 web_search_advanced_exa paralelos → ok
2. Apresentar Nível 1 + AskUserQuestion → ok
3. Receber resposta → ok
4. Nível 2: Claude analisa os resultados + lista fatos-chave → ok
5. AskUserQuestion sub-tópicos → ok
6. web_search_advanced_exa × 4 paralelos → ok
7. Phase Gate: "executar internamente" → modelo PULA, marca 5/5 checks sem evidência
8. Escrever relatório → modelo PULA seção "Contradições Identificadas" silenciosamente
9. CRAAP scores: 95, 92, 90, 88 → distribuição irreal de auto-justificação
10. F4 com "1 substack + 2 LinkedIn + 1 video" → marcado como ALTO sem ≥2 Tier A/B
```

**✅ Execução BOA:**
```
1-6. Mesmas etapas mecânicas
7. Phase Gate: spawn `Agent({subagent_type: Explore, prompt: "verifier independente..."})` → recebe JSON com `verdict`, `weak_facts[]`, `craap_inflation_warning`
8. Escrever relatório SEGUINDO o template literal — incluindo "Contradições Identificadas" mesmo quando vazia (escrever "Nenhuma contradição entre fontes — todas convergiram")
9. CRAAP scores com EVIDÊNCIA POR CRITÉRIO (1 frase pra C, R, A, A, P de cada fonte)
10. Confiança ALTA APENAS se ≥2 fontes Tier A/B independentes (definição programática) por fato-chave
11. Save em ~/pesquisas/ → PostToolUse hook valida formato + bloqueia se inválido
```

## Preparação — carregar tools deferred (AskUserQuestion + Exa)

Algumas tools, nesta harness, são **deferred**: o schema não vem carregado por padrão e chamá-las "cru" falha com `InputValidationError`. **Antes** de rodar qualquer query do Nível 1, carregue:

```
ToolSearch({ query: "select:AskUserQuestion", max_results: 1 })
ToolSearch({ query: "exa", max_results: 8 })
```

- A 1ª linha carrega a `AskUserQuestion` (HITLs dos Níveis 1 e 2). Sem ela, o HITL falha silenciosamente — o modelo escreve o "call" como texto e o fluxo trava.
- A 2ª carrega as tools da Exa. **Pode vir um de dois conectores** — cheque qual existe:
  - **Avançado** (`web_search_advanced_exa` + `web_fetch_exa`): endpoint `mcp.exa.ai/mcp?tools=web_search_advanced_exa,web_fetch_exa`. Tem filtros nativos. **Preferido.**
  - **Simples** (`web_search_exa` + `web_fetch_exa`): conector pronto do Desktop (2 cliques, sem key). Sem filtros nativos — direcione a fonte na query.
  - Se aparecerem com prefixo de servidor (ex.: `mcp__<hash>__web_search_advanced_exa`), use o nome completo retornado pelo ToolSearch.

Pode rodar em paralelo com as queries do Nível 1 (não bloqueia). Se os schemas já aparecerem nas tools do turno, pular.

**Se as tools da Exa NÃO aparecerem neste turno** (MCP não configurado / sem `EXA_API_KEY`): não trave — a skill roda em **modo fallback nativo** com `WebSearch` + `WebFetch`. Ver "Roteamento de motor" acima. (As tools nativas estão sempre disponíveis, inclusive no terminal.)

## Roteamento de motor — Exa OU WebSearch

A skill funciona em **3 modos**. Depois do preload, cheque qual tool de busca existe neste turno e use a primeira disponível nesta ordem:

1. **`web_search_advanced_exa` existe** → **modo Exa avançado** (preferido). Busca neural + filtros nativos: `category`, `includeDomains`/`excludeDomains`, datas. **Sempre** com `textMaxCharacters` (ver Nível 3). É o que dá Tier A cirúrgico.
2. **só `web_search_exa` existe** (conector simples do Desktop) → **modo Exa simples**. Busca neural boa, conteúdo já vem no resultado, mas **sem** filtros nativos — direcione a fonte **descrevendo-a na query** (ex.: "…meta-análise peer-reviewed no PubMed"). `web_fetch_exa` funciona igual.
3. **nenhuma Exa existe** (sem MCP/key) → **modo nativo**: `WebSearch` + `WebFetch`. Sempre disponível, inclusive no terminal. NÃO trave nem peça instalação — roteie e siga.

> Onde a tabela abaixo diz `web_search_advanced_exa`: no **modo 2** troque por `web_search_exa` (sem os params de filtro); no **modo 3** por `WebSearch`. O resto do funil é idêntico nos três.

| Nível / uso | Com Exa | Sem Exa (fallback nativo) |
|---|---|---|
| Nível 1 — Varredura | `web_search_advanced_exa` ×3-5 em paralelo | `WebSearch` ×3-5 em paralelo (mesmos ângulos) |
| Nível 2 — Análise | **você (Claude) raciocina** sobre os resultados do N1; se faltar dado pra comparar, 1-2 `web_search_advanced_exa` direcionados | idem, com `WebSearch` |
| Nível 3 — Deep dive | `web_search_advanced_exa` ×N (direcionando a fonte na query) + `web_fetch_exa` (com `maxCharacters` alto) p/ ler URLs-chave | `WebSearch` ×N por sub-tópico + `WebFetch` pra extrair as URLs de maior valor |
| Phase Gate / gap factual | `web_search_advanced_exa` na query específica | `WebSearch` com query específica + `WebFetch` na fonte |

**O resto é idêntico nos dois caminhos:** HITL entre níveis, fatos-chave, CRAAP scoring, Phase Gate (subagent Explore), e o formato do relatório final. Só muda a tool que busca/extrai. No fallback, cite as URLs do WebSearch/WebFetch como fontes normalmente.

## Flags

### `-f` (full) — funil automático

Se o usuário passar `-f`, rodar o funil completo (1→2→3) sem parar para perguntar entre os níveis. O único HITL mantido é a escolha de sub-tópicos antes do Nível 3 — porque errar os sub-tópicos desperdiça muitas chamadas de busca.

### `-a` (anonymous) — não salva em disco

Se o usuário passar `-a`, **pular o passo de salvar o relatório** em `~/pesquisas/`. O relatório é apresentado normalmente na conversa, mas não persiste como arquivo `.md`.

Ao detectar a flag, avisar logo no início (antes do Nível 1):

```
🕶️ Modo anônimo: relatório não será salvo em ~/pesquisas/.
   Nota: as queries ainda passam pelo provedor de busca (Exa) via API.
```

### Combinações

```
/pesquisa regulamentação de IA         → funil normal com HITL entre cada nível, salva
/pesquisa -f regulamentação de IA      → 1→2 direto, HITL de sub-tópicos, depois 3, salva
/pesquisa -a regulamentação de IA      → funil normal com HITL, NÃO salva
/pesquisa -fa regulamentação de IA     → automático + anônimo (combinável em qualquer ordem: -af, -fa)
```

---

## Nível 1 — Varredura

**Ferramenta:** `web_search_advanced_exa` (ou `WebSearch` no fallback)
**Velocidade:** ~3-5 segundos por query
**Objetivo:** Mapear o terreno com 3-5 ângulos paralelos.

> 💡 **Vantagem da Exa aqui:** o `web_search_advanced_exa` faz busca **neural** (acha a fonte certa por significado, não só por keyword) e **já retorna trechos/conteúdo da página** no resultado — então boa parte do Nível 1 já vem com substância, sem precisar abrir cada link. Se a Exa não estiver disponível neste turno, use `WebSearch` nos mesmos ângulos.

### Como executar

1. Decompor o tema em 3-5 ângulos complementares
2. **CRITICAL — paralelismo obrigatório:** disparar TODAS as chamadas numa **única mensagem** (múltiplas tool_use em paralelo). NÃO chamar uma, esperar resposta, chamar próxima. Isso degrada a velocidade em 5×. Se você está pensando "vou chamar uma, ler resultado, ajustar", PARE — Nível 1 é varredura, não refinamento.

   ❌ Errado: turn 1 chama A, turn 2 chama B, turn 3 chama C
   ✅ Certo: turn 1 chama A + B + C (todas no mesmo bloco de tool calls)

3. **Poucos resultados por query** (5-8) — o Nível 1 é amplo, não fundo. Filtro por domínio e aprofundamento ficam pro Nível 3.

### Entrega do Nível 1

**Regra de formatação:** cada ângulo = 1 frase curta com negrito no rótulo. Máximo ~15 palavras por ângulo. Detalhes ficam pro Nível 2. Separar seções com linha em branco.

```
📡 **Varredura: [tema]**

Pesquisei [N] ângulos:

1. **[Rótulo curto]** — [achado em 1 frase, ~15 palavras máx]
2. **[Rótulo curto]** — [achado em 1 frase]
3. **[Rótulo curto]** — [achado em 1 frase]

**Padrões:** [1-2 frases curtas]

**Gaps:** [o que ainda não sei]
```

Depois chamar:
```
AskUserQuestion({
  questions: [{
    question: "Como quer prosseguir?",
    header: "Próximo passo",
    multiSelect: false,
    options: [
      { label: "Nível 2 (Recommended)", description: "Analisar e comparar os achados em profundidade" },
      { label: "Ajustar foco", description: "Mudar direção antes de aprofundar" },
      { label: "Nível 1 basta", description: "Resumo atual é suficiente, encerrar aqui" }
    ]
  }]
})
```

**Não prosseguir sem resposta do usuário.**

---

## Nível 2 — Análise + Fatos-Chave ★ NOVO

**Ferramenta:** nenhuma obrigatória — **você (Claude) raciocina** sobre os resultados do Nível 1. Se faltar dado pra comparar, faça 1-2 `web_search_advanced_exa` direcionados.
**Velocidade:** ~instantâneo (é síntese sua, sem chamada externa)

> O Nível 2 deixou de terceirizar o raciocínio (era o `perplexity_reason`). Agora **quem analisa é o Claude** — você compara, monta os trade-offs e decide os sub-tópicos com base no que o Nível 1 trouxe. Mais forte e mais rápido. Só busque mais (Exa/WebSearch) se identificar um buraco concreto pra fechar.

**Diferença v3:** Além de comparar e identificar sub-tópicos, identificar explicitamente **3-5 fatos-chave** — afirmações factuais centrais para a conclusão que precisarão ser verificadas por ≥2 fontes independentes no Phase Gate.

### Como executar

1. Analisar os achados do Nível 1 à luz do contexto do usuário
2. Montar comparação direta e tabela de trade-offs
3. Identificar 2-4 sub-tópicos independentes para o Nível 3
4. **Novo:** Listar 3-5 fatos-chave verificáveis (números, datas, causalidades, claims técnicos)

**Exemplos de fatos-chave:**
- "X custa R$Y" → precisa de ≥2 fontes confirmando o preço
- "Framework A é 3x mais rápido que B" → benchmark de ≥2 fontes independentes
- "Empresa X foi fundada em YYYY" → ≥2 fontes com a data

### Entrega do Nível 2

```
🔍 Análise: [tema]

Comparativo:
| Critério | Opção A | Opção B | Opção C |
|----------|---------|---------|---------|
...

Recomendação preliminar: [opção] porque [razão]

Fatos-chave a verificar no Nível 3:
- [ ] [Fato 1] — precisa de ≥2 fontes independentes
- [ ] [Fato 2] — precisa de ≥2 fontes independentes
- [ ] [Fato 3] — precisa de ≥2 fontes independentes
```

### Revisão do enquadramento (Codex) ★ NOVO v3.4

Antes de perguntar quais sub-tópicos aprofundar, mande o Codex (segundo par de olhos, modelo
diferente) tentar derrubar o enquadramento — pergunta clara? sub-tópicos atacam ela mesmo? vale
gastar buscas caras no Nível 3? Ver `references/codex-revisor.md` (Chamada 1). O Claude filtra o
parecer pela regra de ouro do motor compartilhado: ponto que procede e é grave vira A/B pro
usuário; `SEGUIR` → menciona em uma linha e avança. Codex indisponível → o próprio Claude faz a
revisão crítica e informa.

Depois chamar (com os sub-tópicos reais identificados):
```
AskUserQuestion({
  questions: [{
    question: "Quais sub-tópicos quer no deep dive paralelo?",
    header: "Deep dive",
    multiSelect: true,
    options: [
      { label: "Todos (Recommended)", description: "Investigar todos os sub-tópicos em paralelo" },
      { label: "[sub-tópico A]", description: "[por que vale investigar]" },
      { label: "[sub-tópico B]", description: "[por que vale investigar]" },
      { label: "[sub-tópico C]", description: "[por que vale investigar]" }
    ]
  }]
})
```

**Regra: sempre "Todos" como primeira opção + até 3 sub-tópicos específicos. Limite da ferramenta: máx 4 opções. Usar multiSelect: true. Não prosseguir sem resposta.**

---

## Nível 3 — Deep Dive Paralelo com Domain Filters

**Ferramentas:** N × `web_search_advanced_exa` em paralelo + `web_fetch_exa` (extração)
**Velocidade:** ~30-60s (paralelo, não sequencial)

### Passo 1 — Direcionar a fonte (query-phrasing por padrão; filtro nativo é exceção)

> **Calibrado por benchmark (2026-06-24, 5 casos × simples vs filtro nativo):** na maioria dos temas o filtro nativo **NÃO melhora** — a busca neural com uma query bem escrita já entrega ~10/10 Tier A (overlap de 7-8 das 10 URLs com o modo filtrado). O filtro só venceu claro em **1 de 5 casos** (jurídico/oficial) e **piorou feio em 1** (comercial). Então: **query-phrasing é o padrão, filtro nativo é a exceção.**

**Padrão (≈90% dos casos) — descreva a fonte na própria query.** A Exa é neural: pedir o tipo de fonte na frase já ancora o ranking nela. Sem `category`, sem `includeDomains`.

| Tema | Como direcionar (só na query) |
|------|-------------------------------|
| Saúde/medicina | "…meta-análise / RCT peer-reviewed no PubMed" → já dá ~10/10 PubMed/Frontiers |
| Tecnologia/papers | "…paper/survey no arXiv" → já ancora em arxiv.org sozinho |
| Mercado/comparativo | "…comparativo com preço, prós e contras" → deixe o neural rankear |
| Geral | só a query, `type: "auto"` |

**Exceção — use `includeDomains` SÓ quando há fonte OFICIAL/primária que o ranking não alcança:**

| Tema | Filtro que vale a pena |
|------|------------------------|
| Regulação/legal Brasil | `includeDomains: ["gov.br","in.gov.br","planalto.gov.br"]` — **único caso que venceu claro no benchmark** (só ele trouxe o DOU/norma primária; o query-phrasing só achava cópias de terceiros) |
| Fonte oficial específica conhecida | `includeDomains` daquele domínio (órgão setorial, doc oficial de um framework) |

**🚫 Evite — o benchmark mostrou que PIORAM:**
- `category: "company"` → traz ficha/homepage de empresa em vez de comparativo. No caso "melhor CRM" derrubou **100%** do intent (0/10). Pra comparar produtos/serviços, query normal.
- `category: "news"` + `startPublishedDate` → derruba **fontes oficiais sem `publishedDate` limpo** (páginas de release etc.). O neural já prioriza recente — confie e date você mesmo.
- Forçar `category: "research paper"` "por garantia" → redundante: o query-phrasing já dá 10/10. Só use se a query sozinha estiver trazendo blog no meio.

**Como aplicar (a exceção legal, único filtro que compensa):**
```
web_search_advanced_exa(query="LGPD sanções e dosimetria de multas da ANPD, norma vigente", includeDomains=["gov.br","in.gov.br","planalto.gov.br"], numResults=6, type="auto", textMaxCharacters=1500)
```

⚠️ **Trava de payload (CRÍTICA — eval 2026-06-24):** o `web_search_advanced_exa` retorna o **texto inteiro** de cada resultado por padrão (200k–375k chars por chamada → estoura o limite de tokens do turno). **SEMPRE** passe `textMaxCharacters: 1200` (Nível 1) ou `1500` (Nível 3). Pra o texto cheio de uma fonte, use `web_fetch_exa` na URL específica — não despeje tudo na busca.

⚠️ **Travas técnicas (erro 400 / enum):**
- `includeText`/`excludeText` aceitam **só array de 1 item**. Pra vários termos, ponha na `query` ou rode buscas separadas.
- `type` aceita só `auto` | `fast` | `instant`. Use `auto`. NÃO passe `deep`/`deep-reasoning` (a doc da Exa cita, mas o MCP dá erro de enum).
- (Se um dia usar `category: "company"`: ele não aceita `includeDomains` nem data — mas, pelo benchmark, evite essa categoria de qualquer forma.)

*(No fallback sem Exa, use `site:dominio` na query do `WebSearch`.)*

### Passo 2 — Disparar em paralelo (CRITICAL)

Para cada sub-tópico aprovado, criar uma query específica. **Disparar TODAS no mesmo turno = mesma mensagem com múltiplos tool_use blocks.**

⚠️ **Erro mais comum:** chamar `web_search_advanced_exa(A)`, esperar, ler, chamar `web_search_advanced_exa(B)`, esperar... Isso é **sequencial** e a skill perde 60-90% do ganho de velocidade. Quando isso acontece, o user paga 3× mais tempo de espera por nada.

✅ **Forma certa:** uma mensagem do assistant com 3 tool_use blocks (A, B, C). Todos disparam no mesmo wallclock. Aí você espera **uma vez** e recebe os 3 resultados juntos.

Validação rápida: se você está vendo seus próprios outputs intermediários "Pesquisei A, agora vou B" — você quebrou o paralelismo.

```
# Padrão: query-phrasing puro (descreva a fonte na frase). Só adicione includeDomains=[...] no caso-exceção (legal/oficial).
web_search_advanced_exa(query="[sub-tópico A] análise completa, dados concretos [+ tipo de fonte na frase]", numResults=6, type="auto", textMaxCharacters=1500)
web_search_advanced_exa(query="[sub-tópico B] análise completa, dados concretos [+ tipo de fonte na frase]", numResults=6, type="auto", textMaxCharacters=1500)
web_search_advanced_exa(query="[sub-tópico C] análise completa, dados concretos [+ tipo de fonte na frase]", numResults=6, type="auto", textMaxCharacters=1500)
```

### Passo 3 — Scraping de URLs identificadas

**Atenção:** o `web_search_advanced_exa` já traz trechos/highlights — muitas vezes você **nem precisa scrapar**. Só abra a URL inteira quando o trecho não bastar. Aí, ordem (validada em eval real):

1. `web_fetch_exa(urls=[...], maxCharacters=20000)` — 1ª opção: página → markdown limpo **verbatim**. ⚠️ **Passe `maxCharacters` alto** — o default é só **3000** e trunca. Dá pra mandar várias URLs num batch só.
2. Bash: `curl -s "https://r.jina.ai/<url>"` — fallback grátis sem conta, markdown limpo verbatim, ~10s.
3. `WebFetch(url, "<pergunta específica>")` — **NÃO é extrator**: resume/parafraseia via um modelo (no eval devolveu literalmente um "Summary" e perdeu ~90% do texto). Use só pra **confirmar um fato pontual** ("essa página cita X?") ou quando o jina cair — nunca pra extração fiel.
4. Pular a URL, anotar como indisponível.

URLs que valem o scraping:
- Reviews com dados concretos / benchmarks
- Páginas de especificações técnicas
- Threads de fóruns com casos reais

### Passo 4 — CRAAP Scoring ★ MELHORADO v3.1

Para cada fonte relevante encontrada, avaliar nos 5 critérios — cada um de 0 a 20, total de 0 a 100. **Cada score precisa de evidência por critério** (1 frase justificando), não só o total. Sem evidência por critério, score é descartado como performance theatre.

| Critério | O que avaliar | Score |
|----------|--------------|-------|
| **C**urrency | Data de publicação/atualização. Conteúdo recente para o tema? | 0-20 |
| **R**elevance | Fit direto com a pergunta? Ou apenas tangencial? | 0-20 |
| **A**uthority | Quem publicou? Tem credenciais no domínio? Cite o autor/org | 0-20 |
| **A**ccuracy | Corroborada por outras fontes? Tem referências rastreáveis? | 0-20 |
| **P**urpose | Intenção: informar, vender, persuadir, entreter? | 0-20 |

**Bandas de confiança:**
- 80-100: Tier A — usar como fonte primária, citar diretamente
- 60-79: Tier B — usar com ressalva de autoridade
- 40-59: Tier C — mencionar apenas para contexto, não para fatos
- <40: Tier D — descartar ou citar explicitamente como não confiável

**Atenção ao Purpose:** Fonte com score alto em C/R/A/A mas Purpose = "vender" → rebaixar para Tier C independentemente do total.

#### Exemplos calibrados (uso obrigatório de referência)

Use estes 3 exemplos como ancoragem antes de pontuar suas próprias fontes. Sem rubric externa, scores convergem pra inflação (todos 88-95). Compare contra:

**Tier A (92) — peer-reviewed conference paper:**
- Fonte: arXiv 2410.09102 "Instructional Segment Embedding" (ICLR 2025)
- C=20: publicado out/2024, ainda referencial
- R=20: trata exatamente do tema
- A=18: autores Wallace et al. + ICLR é Tier A venue
- A=18: 40+ refs rastreáveis, código replicável
- P=16: pesquisa acadêmica (não 20 porque ainda assim posição própria)
- **Total: 92 → Tier A. Citação direta justificada.**

**Tier B (72) — community blog post de autor identificado:**
- Fonte: dev.to/kanta13jp1 "LangGraph State Machine Patterns"
- C=18, R=20, A=12, A=14, P=8
- A=12 porque autor dev individual sem credencial acadêmica formal
- P=8 porque blog tem viés de "tutorial otimizado"
- **Total: 72 → Tier B. Use com ressalva.**

**Tier C (52) — LinkedIn pulse post:**
- Fonte: LinkedIn pulse "LLMs struggle with negative prompts"
- C=14, R=18, A=4, A=8, P=8
- A=4 porque LinkedIn pulse não tem revisão
- A=8 porque claims sem dados, sem links pra estudos
- **Total: 52 → Tier C. Mencionar apenas para contexto.**

#### Definição programática de "fonte independente"

Duas fontes são **independentes** quando:
1. **Domínios diferentes** (URLs com hostnames distintos após remover `www.`), E
2. **NÃO são duas resenhas/citações do mesmo paper primário** (ex: 2 blogs falando do mesmo arXiv = 1 fonte efetiva, não 2)

Exemplos:
- ✅ INDEPENDENTES: arxiv.org + aclanthology.org (papers diferentes)
- ✅ INDEPENDENTES: code.claude.com docs + github.com/anthropics issue (oficial + community evidence)
- ❌ DEPENDENTES: 3 blogs em domínios diferentes citando o mesmo arXiv (vale como 1)
- ❌ DEPENDENTES: substack.com + linkedin.com mesmo autor mesma claim
- ⚠️ FRACAS: 1 paper primário + 2 mídias sociais sem dados próprios (~1.5 efetivas)

**Regra prática:** se você não consegue dizer "estas 2 fontes seriam acreditadas mesmo sem a outra", não são independentes. Anote no relatório.

### Passo 5 — Phase Gate v3.1 ★ EXTERNAL VERIFIER (mudou)

**MUDANÇA crítica v3.1:** Phase Gate NÃO é mais executado "internamente" pelo modelo. É delegado a um **subagent verifier independente** (read-only, fresh context). Razão: dogfood 2026-04-29 provou que self-verification rubber-stamps; auditor independente não tem incentivo pra rebaixar.

#### Como invocar o verifier

Antes de escrever o relatório final no Nível 3:

```
Agent({
  description: "Phase Gate verifier",
  subagent_type: "Explore",
  prompt: "Você é Phase Gate verifier INDEPENDENTE pra um relatório /pesquisa. Read-only.

  Você recebe: caminho do draft markdown + lista de URLs encontradas.

  Auditar e produzir verification_report.json com:

  {
    \"verifier_model\": \"...\",
    \"draft_path\": \"...\",
    \"timestamp\": \"...\",
    \"checklist\": [
      {\"id\": \"C1\", \"check\": \"Sub-perguntas do Nível 2 respondidas?\", \"status\": \"pass|fail\", \"evidence\": \"linhas X-Y citam ...\"},
      {\"id\": \"C2\", \"check\": \"Dados concretos (números, datas, casos) além de generalidades?\", \"status\": ...},
      {\"id\": \"C3\", \"check\": \"Fatos-chave têm ≥2 fontes INDEPENDENTES (domínios distintos, não-duplicado)?\", \"status\": ..., \"evidence\": \"para fato F1: ... | para F2: ...\"},
      {\"id\": \"C4\", \"check\": \"Fontes Tier A/B (CRAAP ≥60) com EVIDÊNCIA POR CRITÉRIO confirmam conclusões?\", \"status\": ..., \"evidence\": \"...\"},
      {\"id\": \"C5\", \"check\": \"Contradições entre fontes identificadas e endereçadas?\", \"status\": ..., \"evidence\": \"...\"}
    ],
    \"weak_facts\": [\"F1 só tem 1 fonte real\", ...],
    \"craap_inflation_warning\": \"scores 88-95 sem evidência por critério: ...\",
    \"verdict\": \"pass|fail\",
    \"required_fixes\": [\"...\"]
  }

  Output: APENAS o JSON. Não escreva nada além."
})
```

- Se **verdict: pass**: prosseguir pra escrever relatório final
- Se **verdict: fail**: aplicar fixes listados e re-rodar gate
- Se infraestrutura de subagent indisponível: usar checklist abaixo manualmente, MAS rebaixar Confiança final 1 nível (ALTA → MÉDIA)

#### Checklist de suficiência (fallback se verifier não disponível)

```
□ As sub-perguntas definidas no Nível 2 foram respondidas?
□ Há dados concretos (números, datas, casos) além de generalidades?
□ Fatos-chave identificados no Nível 2 têm ≥2 fontes INDEPENDENTES (definição acima)?
□ Fontes Tier A ou B (CRAAP ≥60) confirmam as principais conclusões?
□ Contradições entre fontes foram identificadas e endereçadas?
```

- Se **≥ 4 checks**: prosseguir
- Se **< 4 checks**: para cada gap:
  - Gap **factual pontual** (fato-chave sem 2ª fonte, número específico) → `web_search_advanced_exa` com query específica (ou `WebSearch` no fallback)
  - Gap **analítico/comparativo** (sub-pergunta não respondida, trade-off indefinido) → `web_search_advanced_exa` direcionado

**Regra de ouro do `ask`:** só usar se a pergunta tem UMA resposta correta e factual. Se começa com "depende", usar `reason`.

**Fatos-chave sem 2ª fonte:** Se um fato central do relatório tem apenas 1 fonte, verificar ativamente com `web_search_advanced_exa` (query específica do fato) antes de reportar como confirmado. Se não encontrar 2ª fonte, reportar como "fonte única — não confirmado independentemente".

### Passo 6 — Revisão da conclusão (Codex) ★ NOVO v3.4

O Phase Gate (Passo 5) confere se o relatório TEM evidência suficiente — não se a conclusão faz
sentido. Depois de redigir o relatório e antes de apresentá-lo como fechado, mande o Codex
(segundo par de olhos) tentar derrubar a CONCLUSÃO — ela resolve a pergunta original? existe
caminho mais simples que os próprios dados já sustentam? tem parte que não sustenta a
recomendação? Ver `references/codex-revisor.md` (Chamada 2). Roda em paralelo/depois do Passo 5,
antes da Entrega do Nível 3. `NÃO RESOLVE` (que procede) ou "conclusão mais simples" → PARA, sobe
pro usuário em A/B antes de entregar. `RESOLVE PARCIAL` / pontos menores → viram ressalva na seção
"Contradições Identificadas" ou nota na Recomendação. Codex indisponível → o próprio Claude faz a
revisão crítica e informa.

---

## Entrega do Nível 3

```
📋 Relatório: [tema]
Gerado em: [data] | Sub-tópicos: [N] | Fontes avaliadas: [N] | Fatos-chave verificados: [N/total]

## Resumo Executivo
[2-3 frases com conclusão principal e nível de confiança explícito]

## [Sub-tópico A]
[Achados com dados concretos]
Fatos verificados: [lista com status ≥2 fontes ou "fonte única"]
Fontes principais: [CRAAP score ≥60 com URLs]

## [Sub-tópico B]
[Achados com dados concretos]
Fatos verificados: [lista com status]
Fontes principais: [CRAAP score ≥60 com URLs]

## Comparativo Final
| Critério | Opção A | Opção B |
|----------|---------|---------|
| [dado concreto] | ... | ... |

## Recomendação
[Opção recomendada + justificativa + nível de confiança: ALTO/MÉDIO/BAIXO]

Confiança ALTO: todos fatos-chave com ≥2 fontes Tier A/B
Confiança MÉDIO: maioria dos fatos com ≥2 fontes, algumas Tier C
Confiança BAIXO: fatos com fonte única ou predominância Tier C/D

## Contradições Identificadas
[Pontos onde fontes divergem — mencionar os dois lados com scores CRAAP]

## Status dos Fatos-Chave
| Fato | Fontes | Verificado? |
|------|--------|-------------|
| [fato 1] | [fonte A] + [fonte B] | ✅ confirmado |
| [fato 2] | [fonte A] apenas | ⚠️ fonte única |
| [fato 3] | [fonte A] contradiz [fonte B] | ❌ conflito |

## Fontes Avaliadas (CRAAP)
**Tier A (80-100):**
- [fonte — score — URL — data]

**Tier B (60-79):**
- [fonte — score — URL]

**Tier C/D (<60 — com ressalva):**
- [fonte — score — URL — motivo do rebaixamento]
```

---

## Salvar como arquivo

**Se a flag `-a` foi passada:** pular este passo inteiro. Avisar ao final:

```
🕶️ Modo anônimo: relatório não salvo em disco.
```

**Caso contrário (default):** após apresentar o relatório, salvar automaticamente:

```bash
mkdir -p ~/pesquisas
# Nome: pesquisa-[tema-slug]-[YYYY-MM-DD].md
```

Usar a ferramenta `Write` para criar o arquivo em `~/pesquisas/pesquisa-[tema]-[data].md`.

**Apresentar o arquivo de forma CLICÁVEL (não como texto morto).** Erros que tornam o caminho não-clicável e que você NÃO deve cometer:
- ❌ NÃO ponha o caminho dentro de crase (`` `...` ``) — inline code nunca vira link.
- ❌ NÃO use `~/` no href — o detector de arquivos não expande o til. Use o **caminho absoluto** (`/Users/<user>/pesquisas/...`).
- ✅ Use um **markdown link** com caminho absoluto, assim o usuário clica e abre:

```
📄 Relatório salvo: [pesquisa-[tema]-[data].md](/Users/<user>/pesquisas/pesquisa-[tema]-[data].md)
```

Em seguida, **oferecer abrir** (e abrir se o usuário pedir) com `open <caminho-absoluto>` (macOS) — ou, se a harness tiver uma ferramenta de envio de arquivo (ex.: `SendUserFile`), surfar o arquivo por ela, já que o relatório É o entregável.

---

## Adaptação por contexto

| Tipo | Nível 1 | Nível 2 | Nível 3 | Domain hints |
|------|---------|---------|---------|--------------|
| **Compra** | Opções, preços, reviews | Comparativo + trade-offs | Produto A / Produto B / Problemas reais | Reclame Aqui, Procon, reviews especializados |
| **Tecnologia** | Frameworks, benchmarks | Comparativo técnico | Docs oficiais / Issues / Comunidade | github.com, arxiv.org, docs.[framework] |
| **Mercado** | Tamanho, players | Análise competitiva | Player A / Player B / Regulação | statista.com, ibge.gov.br |
| **Aprendizado** | Conceitos, fontes | Síntese + gaps | Paper / Implementações / Casos reais | arxiv.org, scholar |
| **Decisão** | Opções, critérios, riscos | Matriz de decisão | Risco A / Risco B / Validação | Depende do domínio |

## Comportamento padrão e flags

- `/pesquisa [tema]` (padrão): Funil completo 1→2→3 com HITL entre cada nível. Salva relatório em `~/pesquisas/`.
- `/pesquisa -f [tema]`: Roda 1→2 direto sem perguntar, para só no HITL de sub-tópicos antes do Nível 3, depois completa. Salva.
- `/pesquisa -a [tema]`: Funil normal com HITL, mas **não salva** o relatório em disco (modo anônimo).
- `/pesquisa -fa [tema]` (ou `-af`): Combinação — funil automático + sem salvar.

Se o usuário já está satisfeito no Nível 1 ou 2, não forçar o funil. Perguntar.

---

## Ferramentas

| Ferramenta | Quando usar |
|-----------|-------------|
| `web_search_advanced_exa` | **Níveis 1 e 3** + gap filling — busca **neural** com filtros nativos: `category`, `includeDomains`/`excludeDomains`, datas, `type` (`auto`/`fast`/`instant`). Já traz trechos/conteúdo. Cuidado com as travas de 400 (ver Nível 3 Passo 1) |
| `web_fetch_exa` | Ler URL(s) inteira(s) → markdown verbatim (1ª opção de scraping). **Passe `maxCharacters` alto** (default 3000 trunca); aceita batch |
| `curl -s "https://r.jina.ai/<url>"` | Fallback de scraping — grátis, verbatim, ~10s |
| `WebSearch` | **Motor no fallback** (sem Exa): Níveis 1/3 + gaps. Nativo, sempre disponível |
| `WebFetch` | **Só pra confirmar fato pontual** (resume, NÃO extrai fiel) ou quando jina cai |
| `Write` | Salvar relatório final como .md |

**Análise (Nível 2) não tem tool:** comparativos, trade-offs e síntese são **raciocínio do Claude** sobre os resultados — só busque mais se faltar dado concreto.

---

## Fallback: Exa indisponível ou sem key

Se as tools `web_search_advanced_exa` não existirem no turno (sem `EXA_API_KEY`/MCP) — ou se uma chamada falhar com erro de auth (key inválida / sem crédito):

**Não trave.** Rode o funil inteiro no **motor nativo**: `WebSearch` (Níveis 1/3 + gaps) + `WebFetch`/`r.jina.ai` (extração). Cite as URLs do `WebSearch` como fontes normalmente. Todo o resto — HITL entre níveis, fatos-chave, CRAAP, Phase Gate (subagent Explore), formato do relatório — é **idêntico**. Só muda a qualidade da busca (keyword nativa em vez de neural da Exa).

**Pra ligar/arrumar a Exa** (opcional, só pra recuperar a busca neural):
```
1. Pegar a key em https://dashboard.exa.ai/api-keys (conta grátis, $10 de crédito, sem cartão pra começar)
2. Conferir o MCP: `claude mcp list` deve mostrar o `exa` conectado
   - Se não estiver: `claude mcp add -s user exa -- npx -y exa-mcp-server` (com EXA_API_KEY no ambiente)
   - No Desktop: dá pra usar o conector nativo da Exa (zero config)
3. Reabrir a sessão do Claude Code
```
