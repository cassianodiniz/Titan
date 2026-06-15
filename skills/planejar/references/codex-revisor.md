# Revisor Codex (segundo par de olhos) — específico do /planejar

A mecânica de chamar o Codex (como invocar sem travar, mascarar dado, selar a versão, a **regra
de ouro** de filtrar com prova, o registro obrigatório e o fallback) mora no motor compartilhado:
**`../../_shared/confronto-codex.md` — leia antes de rodar.** Este arquivo cobre só o que é do
`/planejar`: os dois momentos em que o revisor entra e o que fazer com o parecer em cada um.

A `/planejar` usa o Codex GPT-5.5 como revisor independente em dois momentos: a sanidade do
**problema** (Fase 1) e a sanidade do **plano** (Fase 6). É um modelo DIFERENTE do que conduz o
planejamento. Não é a auditoria técnica linha a linha (isso são os subagents de domínio da Fase
6) — aqui a lente é única: **isso faz sentido / resolve o problema?**

O parecer de cada chamada é filtrado pela regra de ouro do motor e o veredito de cada ponto é
registrado (tabela do motor) no arquivo de parecer correspondente: `docs/<nome>-revisao-problema.md`
(Fase 1) e `docs/<nome>-revisao-sanidade.md` (Fase 6).

---

## Chamada 1 — Sanidade do PROBLEMA (Fase 1, uma vez só)

Roda DEPOIS de fechar problema + escopo do MVP + nome, ANTES do gate de aprovação da Fase 1.
Esforço `high` (checagem rápida de enquadramento, não revisão pesada).

Salve o escopo da Fase 1 em `docs/<nome>-escopo.md` (problema, público, fluxos principais, MVP
vs futuro, nome). Monte o input em `/tmp/confronto-input.md` = o prompt abaixo + a linha do selo
(ver motor, seção 2) + o conteúdo do escopo. Depois chame conforme o motor (seção 3):

```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.5 \
  -c model_reasoning_effort="high" \
  --skip-git-repo-check --ignore-user-config --full-auto \
  - < /tmp/confronto-input.md > docs/<nome>-revisao-problema.md 2>/dev/null
```

Prompt a colocar no input:

```
Voce e um revisor critico de PRODUTO. Alguem vai construir algo e definiu o PROBLEMA e o escopo
do MVP. NAO revise codigo, NAO sugira stack. Repita o hash do selo como primeira secao (## Selo).
Uma passada so, responda tres perguntas:
1. O problema declarado e real e claro, ou esta vago / mal formulado?
2. O escopo do MVP ataca ESSE problema, ou esta resolvendo a coisa errada?
3. Voce sugeriria repensar algo ANTES de investir em pesquisa e plano? (escopo grande demais,
   premissa fragil, alternativa obvia ignorada, problema que talvez nem precise de software)

Devolva NESTE formato:
## Selo
<o hash>
## Veredito
SEGUIR  |  REPENSAR
## Pontos
- (no maximo 5, cada um curto e acionavel; se REPENSAR, diga exatamente o que repensar)
Sem elogio, sem resumo do que voce leu.
```

Depois: o Claude confere o selo, lê o parecer, filtra pela regra de ouro do motor e apresenta ao
usuário. `REPENSAR` com ponto que procede → A/B (seguir assim mesmo / ajustar o escopo).
`SEGUIR` → menciona em uma linha e avança o gate normal da Fase 1.

---

## Chamada 2 — Sanidade do PLANO (Fase 6, junto da auditoria técnica)

Roda na Fase 6, em paralelo aos subagents de domínio. Lente: o plano resolve o problema?
Esforço `xhigh` (revisão profunda).

Monte o input em `/tmp/confronto-input.md` = o prompt abaixo + a linha do selo + o caminho do
plano e do escopo (o Codex lê os dois). Depois:

```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.5 \
  -c model_reasoning_effort="xhigh" \
  --skip-git-repo-check --ignore-user-config --full-auto \
  - < /tmp/confronto-input.md > docs/<nome>-revisao-sanidade.md 2>/dev/null
```

Prompt a colocar no input:

```
Voce e o critico de SANIDADE de um plano de implementacao. NAO faca auditoria tecnica linha a
linha (outro revisor cuida disso) e NAO marque coisas 'faltando no codigo' (o codigo ainda nao
foi escrito). Repita o hash do selo como primeira secao (## Selo). Responda so tres perguntas,
com evidencia:
1. O plano RESOLVE o problema declarado? (o problema esta em docs/<nome>-escopo.md; o plano em
   <path-do-plano>)
2. Existe um caminho substancialmente MAIS SIMPLES pro mesmo resultado?
3. Tem parte do plano que NAO serve ao objetivo (peso morto que da pra cortar)?

Devolva NESTE formato:
## Selo
<o hash>
## Veredito
RESOLVE  |  RESOLVE PARCIAL  |  NAO RESOLVE
## Pontos
- (cada um citando a SECAO do plano afetada; se houver caminho muito mais simples ou peso morto,
  seja especifico)
Se o veredito for NAO RESOLVE ou houver um caminho muito mais simples, deixe explicito — isso e
decisao de produto, nao um ajuste tecnico. Sem elogio, sem resumo.
```

Depois: o Claude confere o selo e aplica a regra de ouro do motor.
- `NAO RESOLVE` (que procede) ou "caminho muito mais simples" → **PARA**, sobe pro usuário em
  A/B antes da Fase 7.
- `RESOLVE PARCIAL` / pontos menores que procedem → entram no relatório da Fase 6 como achados
  (prioridade conforme o caso) e são corrigidos na Fase 7.
- Pontos que não procedem → descarta, registra o motivo no relatório.
