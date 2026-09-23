# Phase 2 — Spec, issues and handoff

Use only the decisions confirmed in Phase 1. Do not reopen closed choices; if a gap appears that changes scope, behavior or a test seam, go back to the user before finishing the draft.

Write everything the user may read in the user's language: the approval message, the parent spec and the issues. The user opens the plan files to read them.

## 1. Write the parent spec

Produce a single view of the plan with:

- **Problem:** the user's situation and the desired outcome.
- **Solution:** the proposed behavior, without turning the spec into code.
- **Stories and scenarios:** numbered needs and Given/When/Then scenarios for the relevant flows, failures, permissions and transitions.
- **Implementation decisions:** affected modules or interfaces, contracts, schema and integrations; avoid file paths and snippets that go stale, unless a prototype recorded a decision better than prose.
- **Test decisions:** approved seams, existing precedents and real commands already known.
- **Out of scope:** explicit exclusions.
- **Notes:** risks, migration, rollout and points still `UNKNOWN` that do not block slicing.

Use the domain vocabulary and respect the project's ADRs.

## 2. Slice into executable issues

Break the spec into vertical tracer bullets:

- each issue delivers one complete, verifiable behavior through the layers it needs;
- each issue fits in one fresh context session;
- each issue declares its real blockers;
- issues with no blockers form the frontier available for parallel implementation;
- necessary pre-refactoring comes first;
- a broad refactor uses expand → migrate in green batches → contract, with explicit dependencies.

Each issue must be self-contained. Someone who receives only its file needs to know what to build, why, how to observe that it is done, which decisions are already made and what is not authorized.

Use this format (keep the section titles as written; `$implementar` finds `Varredura (decidida na entrevista)` by name):

```markdown
# <issue-key> — <título>

**Status:** draft | approved | published
**Plano-pai:** <caminho do index.md>
**Tracker:** <URL/ID ou "não publicado">
**Bloqueada por:** <issue-keys ou "nenhuma">

## Resultado
<comportamento completo entregue por esta fatia>

## Cenários e critérios de aceite
- [ ] <resultado observável e concreto>

## Decisões de implementação
- <contrato ou decisão já aprovada>

## Contrato de teste
- Seams aprovados: <interfaces públicas>
- Provas conhecidas: <comandos reais ou UNKNOWN>

## Varredura (decidida na entrevista)
- <cada um dos 9 que toca esta issue>: <critério de aceite acima | já existe em … | fora de escopo porque …>

## Fora de escopo
- <limite desta issue>
```

## 3. Approval before any effect

Write the parent spec and every issue in full, with `Status: draft`, to a temporary directory outside the repository, using the same layout as section 4 (`index.md` + `issues/`). The draft is what the implementer reads. The user approves from the approval message below.

Write the approval message in the user's language, in plain words, for a reader who does not program: they need to understand how the plan works in order to decide well. Tell the plan once, as a story in steps: each fact appears in one place, the step where it happens. How each step is built lives in the draft; the message says what changes for the people involved. Aim for 300 to 500 words. It is, in this order:

1. **The ask, and how it works when it is done** — open with "I need your yes for this plan", then three or four sentences describing the finished result from the user's side: what happens, to whom, in what order.
2. **How I get there, in N steps** — one numbered step per issue, in dependency order: one sentence of about 20 words, in the words the people involved would use, stating what that step does to money, data, people's work or what keeps running, when it does — "Postmark, US$ 15 a month", "the old column is deleted for good", "the 212 members start receiving it". Walk through the Phase 1 decisions one by one; a Phase 1 decision that appears in no issue is a gap: fix the draft before showing the message. When work is delegated to subagents, the step says what they do, what they cannot touch, and what their check does not see.
3. **Where I deviated from what you asked, and why** — one line per deviation, quoting the user's words; then one line per assumption that changes what the user gets, with what to tell me if it is wrong. Or "nothing".
4. **Cost and time** — one line: an estimate, or "I don't know" and why.
5. **What the plan does not cover, and what is still open** — one line each.
6. **Full text** — the draft path, and "ask 'open step N' and I will explain that issue here".
7. **Close** — "Approve?" and the repository path where a yes saves the plan.

The message asks once. Treat the user's yes as approval of the spec content, the issue granularity, the dependencies, the test seams, and permission to save these local artifacts to the path shown.

Iterate until the user approves. Before approval, write no files in the repository, create no issues and apply no labels. After approval, move the draft into the repository paths shown.

Approval must include explicit authorization to persist the local artifacts at the paths shown. It does **not** authorize external publication. For GitHub, Linear or another tracker, ask for explicit authorization stating destination, number of issues and labels; skip the new question only when the user has already authorized those elements unambiguously.

## 4. Persistence without collisions

Never use a `PLAN.md` at the root. Detect the repository's existing convention first; when there is none, use:

```text
docs/plans/<plan-id>/index.md
docs/plans/<plan-id>/issues/<issue-key>-<slug>.md
```

The `<plan-id>` must be unique and stable:

- with a real parent issue: `<tracker>-<id>-<feature-slug>`;
- without one: `<YYYYMMDDTHHMMSSZ>-<feature-slug>`.

Give the plan a short name (2 to 4 words, lowercase, hyphens), unique among the plans in the repository, on the first line of `index.md`: `Plan name: <plan-name>`. The directory keeps the `plan-id`.

`index.md` holds the parent spec, the dependency graph and links to the issues. It is context, not an implementation unit.

Each file in `issues/` holds exactly one issue. Use as `<issue-key>` a stable local key (`01`, `02`, `03`) in dependency order; record the tracker's real ID inside the file, without renaming it after publication. Do not reuse another session's directory and do not overwrite an existing artifact; on collision, generate another `plan-id`.

If external publication is authorized, create the issues in dependency order, record URLs/IDs in the local files and use native blocking relations when they exist. Otherwise, the local files are the canonical issues. Never close or modify an existing parent issue without specific authorization.

## 5. Handoff to implement one issue

List the issues on the current frontier and ask the user to choose the next one. After the choice, offer the two builders, one line each, and let the user pick:

```text
$implementar <plan-name>   (Claude builds)
$gpt-builder <plan-name>   (Codex builds, Claude verifies)
```

The form `$implementar SPEC_FILE="docs/plans/<plan-id>/issues/<issue-key>-<slug>.md"` remains accepted.

One invocation implements one issue. The default flow is sequential: offer another issue only after the current one leaves the frontier or is completed.

If the user asks for parallel implementation, do not assume isolation. Offer several handoffs only when each session already has its own checkout/worktree and branch and the approved artifact is available on a shared base; otherwise explain the prerequisite and keep the flow sequential. Never pass `index.md`, the plan directory or several files in the same invocation.

After implementation, `$build-review` uses the same issue file as the original source, together with the dedicated checklist and the diff left by the builder. After the user approves, offer to start the first issue with either builder; call the one the user picks, only when the user says yes.
