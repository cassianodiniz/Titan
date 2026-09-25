---
name: gpt-implementar
description: Hand a frozen spec (one /spec-plan issue or any locked plan) to OpenAI Codex to IMPLEMENT with full write access, while Claude stays the spec-writer and reviewer. Codex builds from the spec in a --yolo sandbox, Claude reads the full diff like a contributor PR, runs the proof test, and iterates fixes via the SAME Codex session up to MAX_FIX_ROUNDS before taking over. Claude commits locally after each verified round; push and PR wait for the user. Use when the user says "/gpt-implementar" (or the old name "/gpt-builder"), "have codex build this", "codex implement the plan", "hand the plan to codex", "delegate the build to codex", or right after a plan survives /spec-plan or /gpt-optimizer and they choose Codex for implementation. Also for standalone delegation: refactors, mechanical migrations, bug fixes with a known repro, test/coverage writing — anything that reads as a work order. NOT for tiny edits (~<20 lines — delegation overhead loses), NOT for design work (if writing the spec forces decisions, that's /spec-plan first), NOT for reviewing existing code (/build-review), and NOT for anything needing Claude-session tools (MCP, secrets, browser).
---

# gpt-implementar — Codex Types, Claude Verifies

Same job and same bar as `/implementar`; only the hands change. **Codex types the code in a separate session; Claude does everything before and after the build** — gates, start marker, checklist, commits, verification, report — and treats every Codex claim as advisory until proven. The artifacts are the ones `/implementar` leaves (start marker, issue checklist, commits after the marker, final report), so `/build-review` reads the result the same way.

**Spec quality decides success.** Codex starts with zero session context — everything it needs must be in the prompt. An issue approved in `/spec-plan` is a frozen spec; that's the ideal input.

## Prerequisites (verify once, fast)

- `codex --version` ≥ 0.156 (o `gpt-6-sol` exige CLI recente; a 0.154 recusa com "not supported when using Codex with a ChatGPT account" — HTTP 400). Verificado em 0.156.0 (22/09/2026).
- Codex authenticated (prior `codex login`; ChatGPT account is fine). On auth/model error, surface it — don't silently retry.
- **Modelo fixado em `gpt-6-sol` com `model_reasoning_effort="medium"`.** A entrega vai inteira pro Codex, então o executor é o mais forte da família; esforço médio porque `max` num executor só acrescenta lentidão. NÃO remova o `--model` NEM o `-c model_reasoning_effort`: sem eles o Codex lê `~/.codex/config.toml`, e o app do Codex reescreve esse arquivo sozinho ao atualizar. Esforços aceitos pela CLI: `low, medium, high, xhigh, ultra, max`.
- **Echo the active model + effort at kickoff** so the user can confirm: the commands pin `gpt-6-sol` and `model_reasoning_effort="medium"`, so state exactly that (não o `model`/`effort` do `~/.codex/config.toml`, que os overrides sobrepõem) junto com os demais tunables resolvidos. If the user objects, stop before launching the build.
- **Bug conhecido:** `codex exec` com a família `gpt-5.6` (not yet confirmed on `gpt-6`) pode **não executar comandos de shell em silêncio** em certas configs (`openai/codex#31894`). "Teste passou" sem saída real de comando é o que o fiscal (Step 3) caça — não confie no relato.
- **Referências compartilhadas com `/implementar`** (mesmo repo `Skills`, relativas a esta skill: `../implementar/references/`): `checklist.md`, `fiscal.md`, `relatorio.md`, `tdd/tdd.md`. Leia cada uma no passo que a cita; não copie o conteúdo pra cá.
- **Codex has a native image-generation tool** in `codex exec` sessions (ChatGPT-account backed, no API key; saves PNGs to disk headless). Specs may therefore include "generate these image assets yourself" steps: name exact file paths, dimensions, and style in the prompt contract.
- Run from the target repo's root (both `exec` and `resume` then need no `-C`; `resume` doesn't support `-C` anyway).

## Tunables (read from args, else default)

| Var | Default | Meaning |
|-----|---------|---------|
| `SPEC_FILE` | the target issue when the source is a `/spec-plan` plan (see Source contract); otherwise the spec the user names | The one approved spec Codex builds. |
| `CHECKLIST` | `.checks/<plan-id>-<issue-key>-<slug>.md` | The issue's checklist; other sources keep a name fitting that source. |
| `MAX_FIX_ROUNDS` | `2` | Fix iterations via resume before Claude takes over and finishes directly. |
| `PROOF_CMD` | from spec | Exact test/verify command Codex must run as proof. If the spec lacks one, ask the user ONE question to get it before launching. |
| `BASE_SHA` | the start marker | Start of the diff range the fiscal verifies (`BASE_SHA..HEAD`). |

Round records go to `<CHECKLIST without .md>.log.md`, next to the checklist — never a shared file at the repo root.

Echo resolved values before starting.

## Source contract for spec-plan

When `SPEC_FILE` comes from `$spec-plan`, it must identify exactly one approved issue file under the plan's `issues/` directory.

- Build only the target issue. Sibling issues and the parent `index.md` are context, not authorization: nothing they describe is built: it stays out of the checklist and the diff.
- If `SPEC_FILE` is an index, a directory, or a document containing multiple implementation issues without one explicit target, stop and ask which issue to build.
- Preserve the approved issue as the original source for `$build-review`; do not rewrite it during the build.

When the argument is a plan name, find the plan whose `index.md` declares `Plan name: <that name>`. Zero matches or more than one: stop and ask. In that plan, take the first issue in dependency order that is `approved`, has every blocker finished (`Status: done`), and has no start marker in `git log`. Say which issue you will build, in one line, and wait for the user's yes before anything else.

With no argument and no hand-off in this conversation, never choose a plan yourself — not the most recent, not the one in the conversation. List the plans that have pending issues, by name, and ask.

## Step 0 — Gates (before any Codex launch)

1. **Spec gate.** `SPEC_FILE` must exist and read as a work order (goal, concrete steps, bounds). No spec → offer `/spec-plan` (interview first) or `/gpt-optimizer` (have a plan, want it stress-tested) instead. If the user insists on building from a rough idea, write the spec WITH them first — that's design, and design stays with Claude.
2. **Clean-tree gate.** `git status -sb`. Dirty working tree → STOP and ask the user to commit or stash first. Non-negotiable: Codex writes with full access, and a dirty tree means its diff can't be isolated or cleanly reverted.
3. **Start marker.** With the tree clean and nothing staged, commit the marker right away, before writing the checklist: `git commit --allow-empty -m "chore(checks): start <CHECKLIST file name, without .md>"`. It carries no code; it is `BASE_SHA`, and `$build-review` finds it by that message and reviews everything after it.
4. **Checklist gate.** Antes de qualquer código, escreva `CHECKLIST` no formato de `../implementar/references/checklist.md`: um item por afirmação observável da spec, **prova nomeada por item** (o teste que decide aquele item — nunca `PROOF_CMD` inteiro como prova de tudo), recuse em vez de chutar (item sem prova nomeável, sem valor concreto ou sem limite dito → pergunte), e a varredura dos 9 esquecidos com "onde caiu". Leave every `Red:` line empty; Codex fills it while building. O checklist é a barra: não muda durante a construção, e é o que o contrato e o fiscal apontam. Commit it after the marker.
5. Confirm scope in one line, then go. No round-by-round approvals.

## Step 1 — The build prompt (contract, via temp file)

Never inline-quote the prompt — write it to a temp file. Fill this contract completely; derive it from the spec's sections:

```bash
P=$(mktemp)
cat >"$P" <<'EOF'
GOAL: Pronto quando cada item de <CHECKLIST> tem sua prova verde:
  <C1 - afirmação> · <C2 - ...> (copie os itens; são a barra)
SPEC: Read <SPEC_FILE>. It is a frozen, already-reviewed spec. When it is one
  issue of a plan, the other issues are out of scope: build nothing they describe.
  Checklist: <CHECKLIST>. Implement it exactly. If a step is
  impossible as written, stop and report the contradiction — do not redesign.
  Order (TDD): read <absolute path of ../implementar/references/tdd/tdd.md>
  first. For each check, write its test at the public seam, run only that file,
  and watch it FAIL AT THE ASSERTION. "Cannot find module", an import or
  syntax error, or "no tests collected" is not a failure yet: add the minimal
  skeleton that lets the test load, then watch it fail at the assertion.
  Write that assertion failure on the check's `Red:` line in the checklist.
  Then write the minimum that passes and paste the output PASSING. Não rode a
  suíte completa; isso é do Claude.
KEY PATHS: <files/dirs Codex will touch or must read first>
CONSTRAINTS: <"don't touch X", style rules, deps that must not change>.
  In the checklist, fill only the `Red:` lines and append `Landing` rows;
  change nothing else in it.
  Never weaken an assertion, delete a test, or skip one to make a suite
  pass. If a test is genuinely wrong, stop and report it — do not adjust it.
  Never simplify away: input validation at trust boundaries, error handling
  that prevents data loss, security measures, accessibility basics, anything
  the spec asks for. Trace every file the change touches before writing.
  A door you discover while building (a decision with no way back): append
  its row to `Landing` in the checklist — its literal shape and the
  alternative you rejected — BEFORE writing the code that closes it.
  Não faça commit nem push; não crie branch; não abra outros agentes.
NON-GOALS: <explicitly out of scope — from the spec's out-of-scope section>
PROOF: Para cada item, rode o teste nomeado na prova dele e cole a saída real
  com o código de saída. Depois `<PROOF_CMD>` com saída completa.
OUTPUT: End with a report — files changed (one line each: path + what/why),
  proof output per item, decisions the spec didn't fix, and any deviations
  from the spec with reasons.
EOF
```

Same shape as `../implementar/references/contrato.md` — one contract per **whole delivery**, never per file or step: each extra run re-reads the same code and re-pays the handoff.

## Step 2 — Launch Codex (fresh session, capture `thread_id`)

```bash
codex exec --model gpt-6-sol -c model_reasoning_effort="medium" --yolo --json -o /tmp/gpt-implementar.txt - <"$P" 2>/dev/null | grep '"type":"thread.started"'
```

- Prompt goes via stdin (`- <"$P"`) — this both avoids quoting bugs AND sidesteps the non-TTY stdin hang (`codex exec` blocks forever waiting on stdin EOF under Claude Code's Bash tool; feeding the file gives immediate EOF).
- Parse `thread_id` from the `{"type":"thread.started","thread_id":"..."}` line → `THREAD_ID`. Codex's final report lands in `/tmp/gpt-implementar.txt` — read that file; don't parse the JSONL stream for content.
- **Launch refused.** If the permission system blocks the launch (a denied prompt, or a refusal such as "Create Unsafe Agents"), stop and tell the user, quoting the refusal. Do not swap `--yolo` for another flag and do not build it yourself: the point of this skill is that Codex types the code, and a silent swap hides that the build did not happen the way the user chose. The start marker stays: tell the user this issue has started and that the next run must name its file (`SPEC_FILE=<path>`), because selection by plan name skips issues that already have a marker.
- `2>/dev/null` suppresses cosmetic MCP/auth stderr noise. Confirm success by the report file + a `thread.started` line; neither → failed run (auth/model) — stop and tell the user.
- **Timing:** foreground with `timeout: 600000` on the Bash tool call (default 2-min tool timeout kills real builds). If the spec is clearly >10 min of work (multi-file feature, migration, anything with image generation), launch with `run_in_background: true` instead and read the `-o` file when it exits. Don't kill a quiet background run early — Codex builds are legitimately slow.
- **Heads-up on completion (required):** when a background Codex run finishes, the FIRST line of your next message to the user must be a loud standalone banner — `🔔 CODEX FINISHED — <what> (exit ok/fail) — verifying now` — BEFORE any verification output. The user is not watching tool calls; never let a completed build slide silently into the verify phase.

## Step 3 — Verify, commit, verify again (every round)

Codex's report is advisory. Two different eyes, neither of them Codex:

1. **Claude, judgment.** `git status -sb` + read the FULL diff (working tree against `BASE_SHA`). Judge it like a contributor PR: correctness, spec fidelity, style match with surrounding code, nothing touched outside scope. Check that every `Red:` line holds an assertion failure, and that every door visible in the diff has its `Landing` row. Run `PROOF_CMD` yourself. Codex's pasted output doesn't count as proof.
2. **Commit.** Claude commits the round's work locally with Conventional Commits, staging each file by name (`git add <path>`) so the commit holds only this round. Codex never commits. An approved issue authorises local commits; push, PR and deploy wait for the user.
3. **Fiscal, evidence.** Dispatch a fresh subagent (economical model) with the briefing in `../implementar/references/fiscal.md`: it gets the checklist, `BASE_SHA..HEAD`, and the spec; runs every item's proof itself at HEAD, confirms each named test exists and ran, cites `file:line` of the settling assertion, compares spec vs checklist for omissions/contradictions, fixes nothing, returns PASS/FAIL with a ranked gap list. Round 2+ is scoped: the fix's diff plus every non-PASS verdict; proofs always re-run at the new HEAD. Why after the *first* build and not only at the end: its FAIL list is the cheapest possible fix list for the resume round. Why not Claude doing it: Claude wrote the spec and the contract — same head that would miss the same gap.
4. Append to the round log: `### Round <n> — Codex build` + its report summary + `### Claude's verdict` + `### Fiscal <n>: PASS|FAIL, <k>/<N> proven` + what passed/failed. The log entry and the fiscal's verdict are written after the round's commit, so they go into the **next** commit; the final commit (Step 5) carries the last entry, the last fiscal verdict and `Status: done`.

Gaps from either eye → Step 4. Both green → Step 5.

## Step 4 — Fix loop (same session, bounded)

Problems found → resume the SAME session (Codex keeps its context; cheaper and better than a fresh run). Write the fix list to a temp file (`$P2`), same contract discipline: exact problem, exact file, proof expected.

```bash
# resume has no --yolo and no -C: run from the repo dir and spell the long flag,
# or Codex inherits config.toml's sandbox (possibly read-only) and can't write.
codex exec resume "$THREAD_ID" --model gpt-6-sol -c model_reasoning_effort="medium" --dangerously-bypass-approvals-and-sandbox --json \
  -o /tmp/gpt-implementar.txt - <"$P2" 2>/dev/null >/dev/null
```

Re-verify (Step 3) after each round. After `MAX_FIX_ROUNDS` failed rounds: STOP delegating — Claude takes over and finishes the remaining fixes directly. Log the takeover. Ping-ponging trivia through delegation burns more than it saves.

## Step 5 — Deliver

Before the final message, read `../implementar/references/relatorio.md` and follow it — the same report `/implementar` gives, including `**Status:** done` on a `/spec-plan` issue and the closing offer to run `/build-review` in this session. Make the final commit before the report: the last round-log entry, the last fiscal verdict and the `Status: done` line, staged by name — nothing of the build may stay uncommitted, or the clean-tree gate blocks the next run. Add two things it does not know about: the rounds used and every deviation from the spec. Also, when the change is visual:

- **Prévia.** Mudou tela ou visual → suba o servidor local e abra o autologin já na tela alterada (`preview_start` quando houver). Dado de teste vai no banco **local**, nome começando por `TESTE`, valores no relatório; nunca em produção. Confirme o critério visual na própria tela antes de entregar.

Rejected by the user → ask what's wrong, route back to Step 4 (or take over directly if fix rounds are spent).

**Próximo passo (fluxo):** `/spec-plan` → **`/gpt-implementar`** (aqui) → `/build-review`. O fiscal daqui prova a aderência à spec; o build-review é o pente-fino de qualidade por cima.

## Hard rules

- Each issue starts on its own yes. Before the start marker of any issue - the first one of the session or the next one after a merge - say which issue, in one line, and wait for the user's yes to that issue. "Merge feito", "ok", or an answer to your own "next I'll start X" closes the current issue; it is not that yes. A plan you announced in an earlier message authorises nothing.
- Clean tree before launch. Always. No exceptions. Start marker before the checklist.
- Claude never skips the diff read, and never skips the fiscal. Codex claims are advisory until Claude has read the diff, run the proof, and a fresh fiscal has proven every checklist item at HEAD.
- No code before the checklist; no checklist item without a named proof.
- Fix loop terminates at `MAX_FIX_ROUNDS` — then Claude takes over. No unbounded delegation ping-pong.
- Codex never commits. Claude commits locally after each verified round; push, PR, releases and GitHub mutations wait for the user's explicit go-ahead.

## What NOT to do

- Don't build without a spec — that's designing by delegation, and it fails. Route to `/spec-plan` first.
- Don't use for ~<20-line single-obvious-change edits — just make the edit.
- Não fixe variantes `-codex` do modelo (dão 400 em conta ChatGPT). O `--model gpt-6-sol -c model_reasoning_effort="medium"` dos comandos é deliberado — não remova nem troque sem pedido explícito do usuário.
- Don't slice the delivery into several Codex runs to "parallelize" — one whole delivery per contract.
- Don't resume with `--last` — capture and use the explicit `THREAD_ID` (parallel sessions make `--last` grab the wrong thread). And ECHO the id into the command visibly before running: `resume` with a missing/garbage id can silently fall back to the most recent session instead of erroring — a wrong-target resume looks exactly like a successful one.
- Don't parse the JSONL stream for the report — read the `-o` file.
