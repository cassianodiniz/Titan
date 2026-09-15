---
name: gpt-builder
description: Hand a frozen spec (PLAN.md or any locked plan) to OpenAI Codex to IMPLEMENT with full write access, while Claude stays the spec-writer and reviewer — the exact role-flip of a read-only code review. Codex builds from the spec in a --yolo sandbox, Claude reads the full diff like a contributor PR, runs the proof test, and iterates fixes via the SAME Codex session up to MAX_FIX_ROUNDS before taking over. Human approves the diff before any commit. Use when the user says "/gpt-builder", "have codex build this", "codex implement the plan", "hand the plan to codex", "delegate the build to codex", or right after a plan survives /spec-plan and they choose Codex for implementation (Act 3). Also for standalone delegation: refactors, mechanical migrations, bug fixes with a known repro, test/coverage writing — anything that reads as a work order. NOT for tiny edits (~<20 lines — delegation overhead loses), NOT for design work (if writing the spec forces decisions, that's /spec-plan first), NOT for reviewing existing code, and NOT for anything needing Claude-session tools (MCP, secrets, browser).
---

# gpt-builder — Codex Types, Claude Verifies

The role-flip of a read-only review: there, Claude builds the plan and Codex critiques read-only. Here, **Codex is the builder with write access; Claude is the spec-writer and reviewer.** Codex implements a frozen spec end-to-end; Claude judges the diff like a contributor PR, demands proof, and iterates fixes in the same Codex session. The human enters at exactly two points: kickoff and diff sign-off.

**Spec quality decides success.** Codex starts with zero session context — everything it needs must be in the prompt. A plan that survived `/spec-plan` already is a frozen spec; that's the ideal input.

## Prerequisites (verify once, fast)

- `codex --version` ≥ 0.144 (a família `gpt-5.6-*` exige CLI recente; CLI antiga recusa com "requires a newer version of Codex" — HTTP 400). Verificado em 0.153.4.
- Codex authenticated (prior `codex login`; ChatGPT account is fine). On auth/model error, surface it — don't silently retry.
- **Modelo fixado em `gpt-5.6-sol` com `model_reasoning_effort="medium"`.** A entrega vai inteira pro Codex, então o executor é o mais forte da família; esforço médio porque `max` num executor só acrescenta lentidão. NÃO remova o `--model` NEM o `-c model_reasoning_effort`: sem eles o Codex lê `~/.codex/config.toml`, e o app do Codex reescreve esse arquivo sozinho ao atualizar. Esforços aceitos pela CLI: `low, medium, high, xhigh, ultra, max`.
- **Echo the active model + effort at kickoff** so the user can confirm: the commands pin `gpt-5.6-sol` and `model_reasoning_effort="medium"`, so state exactly that (não o `model`/`effort` do `~/.codex/config.toml`, que os overrides sobrepõem) junto com os demais tunables resolvidos. If the user objects, stop before launching the build.
- **Bug conhecido:** `codex exec` com a família `gpt-5.6` pode **não executar comandos de shell em silêncio** em certas configs (`openai/codex#31894`). "Teste passou" sem saída real de comando é o que o fiscal (Step 3) caça — não confie no relato.
- **Referências desta skill** na pasta `references/` (relativa a este `SKILL.md`): `checklist.md`, `contrato.md`, `fiscal.md`, `relatorio.md`. Leia cada uma no passo que a cita; não copie o conteúdo pra cá.
- **Codex has a native image-generation tool** in `codex exec` sessions (ChatGPT-account backed, no API key; saves PNGs to disk headless). Specs may therefore include "generate these image assets yourself" steps: name exact file paths, dimensions, and style in the prompt contract.
- Run from the target repo's root (both `exec` and `resume` then need no `-C`; `resume` doesn't support `-C` anyway).

## Tunables (read from args, else default)

| Var | Default | Meaning |
|-----|---------|---------|
| `SPEC_FILE` | `PLAN.md` | The frozen spec Codex implements. |
| `MAX_FIX_ROUNDS` | `2` | Fix iterations via resume before Claude takes over and finishes directly. |
| `LOG_FILE` | `PLAN-REVIEW-LOG.md` | Append-only build transcript. If it exists (Act 1/2 ran), append `## Act 3 — Build`; else create it. |
| `PROOF_CMD` | from spec | Exact test/verify command Codex must run as proof. If the spec lacks one, ask the user ONE question to get it before launching. |
| `BASE_SHA` | `git rev-parse HEAD` at Step 0 | Start of the diff range the fiscal verifies (`BASE_SHA..HEAD`). Record it before Codex writes anything. |

Echo resolved values before starting.

## Step 0 — Gates (before any Codex launch)

1. **Spec gate.** `SPEC_FILE` must exist and read as a work order (goal, concrete steps, bounds). No spec → offer `/spec-plan` (interview first) instead. If the user insists on building from a rough idea, write the spec WITH them first — that's design, and design stays with Claude.
2. **Clean-tree gate.** `git status -sb`. Dirty working tree → STOP and ask the user to commit or stash first. Non-negotiable: Codex writes with full access, and a dirty tree means its diff can't be isolated or cleanly reverted. Then record `BASE_SHA`.
3. **Checklist gate.** Antes de qualquer código, escreva `.checks/<feature>.md` no formato de `references/checklist.md`: um item por afirmação observável da spec, **prova nomeada por item** (o teste que decide aquele item — nunca `PROOF_CMD` inteiro como prova de tudo), recuse em vez de chutar (item sem prova nomeável, sem valor concreto ou sem limite dito → pergunte), e a varredura dos 9 esquecidos com "onde caiu". O checklist é a barra: não muda durante a construção, e é o que o contrato e o fiscal apontam.
4. Confirm scope in one line, then go. No round-by-round approvals; the human gate is at the end.

## Step 1 — The build prompt (contract, via temp file)

Never inline-quote the prompt — write it to a temp file. Fill this contract completely; when chained from a grill/review skill, derive it from the plan's sections:

```bash
P=$(mktemp)
cat >"$P" <<'EOF'
GOAL: Pronto quando cada item de .checks/<feature>.md tem sua prova verde:
  <C1 - afirmação> · <C2 - ...> (copie os itens; são a barra)
SPEC: Read <SPEC_FILE> at the repo root. It is a frozen, already-reviewed spec.
  Checklist: .checks/<feature>.md. Implement it exactly. If a step is
  impossible as written, stop and report the contradiction — do not redesign.
  Ordem (TDD): para cada item, escreva o teste na junção pública, rode só esse
  arquivo e cole a saída FALHANDO; escreva o mínimo que passa e cole a saída
  PASSANDO. Não rode a suíte completa; isso é do Claude.
KEY PATHS: <files/dirs Codex will touch or must read first>
CONSTRAINTS: <"don't touch X", style rules, deps that must not change>.
  Não faça commit nem push; não crie branch; não abra outros agentes.
NON-GOALS: <explicitly out of scope — from the plan's Out of scope section>
PROOF: Para cada item, rode o teste nomeado na prova dele e cole a saída real
  com o código de saída. Depois `<PROOF_CMD>` com saída completa.
OUTPUT: End with a report — files changed (one line each: path + what/why),
  proof output per item, decisions the spec didn't fix, and any deviations
  from the spec with reasons.
EOF
```

Same shape as `references/contrato.md` — one contract per **whole delivery**, never per file or step: each extra run re-reads the same code and re-pays the handoff.

## Step 2 — Launch Codex (fresh session, capture `thread_id`)

```bash
codex exec --model gpt-5.6-sol -c model_reasoning_effort="medium" --yolo --json -o /tmp/gpt-builder.txt - <"$P" 2>/dev/null | grep '"type":"thread.started"'
```

- Prompt goes via stdin (`- <"$P"`) — this both avoids quoting bugs AND sidesteps the non-TTY stdin hang (`codex exec` blocks forever waiting on stdin EOF under Claude Code's Bash tool; feeding the file gives immediate EOF).
- Parse `thread_id` from the `{"type":"thread.started","thread_id":"..."}` line → `THREAD_ID`. Codex's final report lands in `/tmp/gpt-builder.txt` — read that file; don't parse the JSONL stream for content.
- `2>/dev/null` suppresses cosmetic MCP/auth stderr noise. Confirm success by the report file + a `thread.started` line; neither → failed run (auth/model) — stop and tell the user.
- **Timing:** foreground with `timeout: 600000` on the Bash tool call (default 2-min tool timeout kills real builds). If the spec is clearly >10 min of work (multi-file feature, migration, anything with image generation), launch with `run_in_background: true` instead and read the `-o` file when it exits. Don't kill a quiet background run early — Codex builds are legitimately slow.
- **Heads-up on completion (required):** when a background Codex run finishes, the FIRST line of your next message to the user must be a loud standalone banner — `🔔 CODEX FINISHED — <what> (exit ok/fail) — verifying now` — BEFORE any verification output. The user is not watching tool calls; never let a completed build slide silently into the verify phase.

## Step 3 — Verify (Claude in-session + independent fiscal, every round)

Codex's report is advisory. Two different eyes, neither of them Codex:

1. **Claude, judgment.** `git status -sb` + read the FULL diff (`git diff BASE_SHA..HEAD` plus working tree). Judge it like a contributor PR: correctness, spec fidelity, style match with surrounding code, nothing touched outside scope. Run `PROOF_CMD` yourself. Codex's pasted output doesn't count as proof.
2. **Fiscal, evidence.** Dispatch a fresh subagent (economical model) with the briefing in `references/fiscal.md`: it gets the checklist, `BASE_SHA..HEAD`, and the spec; runs every item's proof itself at HEAD, confirms each named test exists and ran, cites `file:line` of the settling assertion, compares spec vs checklist for omissions/contradictions, fixes nothing, returns PASS/FAIL with a ranked gap list. Round 2+ is scoped: the fix's diff plus every non-PASS verdict; proofs always re-run at the new HEAD. Why after the *first* build and not only at the end: its FAIL list is the cheapest possible fix list for the resume round. Why not Claude doing it: Claude wrote the spec and the contract — same head that would miss the same gap.
3. Append to `LOG_FILE` under `## Act 3 — Build`: `### Round <n> — Codex build` + its report summary + `### Claude's verdict` + `### Fiscal <n>: PASS|FAIL, <k>/<N> proven` + what passed/failed.

Gaps from either eye → Step 4. Both green → Step 5.

## Step 4 — Fix loop (same session, bounded)

Problems found → resume the SAME session (Codex keeps its context; cheaper and better than a fresh run). Write the fix list to a temp file (`$P2`), same contract discipline: exact problem, exact file, proof expected.

```bash
# resume has no --yolo and no -C: run from the repo dir and spell the long flag,
# or Codex inherits config.toml's sandbox (possibly read-only) and can't write.
codex exec resume "$THREAD_ID" --model gpt-5.6-sol -c model_reasoning_effort="medium" --dangerously-bypass-approvals-and-sandbox --json \
  -o /tmp/gpt-builder.txt - <"$P2" 2>/dev/null >/dev/null
```

Re-verify (Step 3) after each round. After `MAX_FIX_ROUNDS` failed rounds: STOP delegating — Claude takes over and finishes the remaining fixes directly. Log the takeover. Ping-ponging trivia through delegation burns more than it saves.

## Step 5 — Deliver + human gate (diff sign-off)

Before asking for the commit, deliver it the way `references/relatorio.md` prescribes — for someone who never opened a terminal:

- **Prévia.** Mudou tela ou visual → suba o servidor local e abra o autologin já na tela alterada (`preview_start` quando houver). Dado de teste vai no banco **local**, nome começando por `TESTE`, valores no relatório; nunca em produção. Confirme o critério visual na própria tela antes de entregar.
- **Relatório leigo.** Onde estamos (uma frase); como testar (onde clicar, o que preencher, o que deve aparecer); o que foi verificado (tabela: comando → resultado, incluindo o veredito do fiscal e "revisão geral pendente"); decisões que a spec não fixava; rounds used; spec deviations. Termo técnico só com comparação do mundo real antes; `R\$` escapado.

Then ask: *"Codex built it, proof passes, fiscal PASS, diff reviewed. Commit?"*

- Commit ONLY on yes — and Claude writes the commit, never Codex.
- Rejected → ask what's wrong, route back to Step 4 (or take over directly if fix rounds are spent).

## Hard rules

- Clean tree before launch. Always. No exceptions.
- Claude never skips the diff read, and never skips the fiscal. Codex claims are advisory until Claude has read the diff, run the proof, and a fresh fiscal has proven every checklist item at HEAD.
- No code before the checklist; no checklist item without a named proof.
- Fix loop terminates at `MAX_FIX_ROUNDS` — then Claude takes over. No unbounded delegation ping-pong.
- Commits, pushes, releases, GitHub mutations: Claude-side only, after the human gate. Codex never commits.
- `LOG_FILE` is the deliverable — with Acts 1/2 it tells the whole story: grilled → reviewed → built → verified.

## What NOT to do

- Don't build without a spec — that's designing by delegation, and it fails. Route to `/spec-plan` first.
- Don't use for ~<20-line single-obvious-change edits — just make the edit.
- Não fixe variantes `-codex` do modelo (dão 400 em conta ChatGPT). O `--model gpt-5.6-sol -c model_reasoning_effort="medium"` dos comandos é deliberado — não remova nem troque sem necessidade.
- Don't slice the delivery into several Codex runs to "parallelize" — one whole delivery per contract.
- Don't resume with `--last` — capture and use the explicit `THREAD_ID` (parallel sessions make `--last` grab the wrong thread). And ECHO the id into the command visibly before running: `resume` with a missing/garbage id can silently fall back to the most recent session instead of erroring — a wrong-target resume looks exactly like a successful one.
- Don't parse the JSONL stream for the report — read the `-o` file.
- Don't let Codex commit, and don't auto-commit yourself — human gate first.
