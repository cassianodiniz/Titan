---
name: implementar
description: Use when the user explicitly invokes /implementar, $implementar or @implementar to build work already decided in a spec, plan, tickets or issue of the current repository. Not for deciding what to build.
disable-model-invocation: true
---

# Implementar

Implement the work described by the user in the spec or tickets.

## Source contract for spec-plan

When `SPEC_FILE` comes from `$spec-plan`, it must identify exactly one approved issue file under the plan's `issues/` directory.

- Implement only the target issue. Sibling issues and the parent `index.md` are context, not authorization.
- Read the parent index when linked, but do not absorb its other issues into scope.
- If `SPEC_FILE` is an index, a directory, or a document containing multiple implementation issues without one explicit target, stop and ask which issue to implement.
- Use an issue-specific checklist path such as `.checks/<plan-id>-<issue-key>-<slug>.md` so concurrent plans do not share a checklist.
- Preserve the approved issue as the original source for `$build-review`; do not rewrite it during implementation.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end. You decide how. Write the tests from the checklist, implement, run each proof, commit in coherent pieces with Conventional Commits to the current branch..

Two boundaries, and they are about scope rather than care. New capability nobody asked for and unrelated refactors are not yours to add - surface them and move on. Everything else inside the work at hand is the work: a guard clause, a log line, a clear error message, a test beyond the proofs when you can say what *should* happen at an edge the checklist did not name. Extra tests are welcome and there is no quota.

Doors get discovered while building, and deciding them is yours - stopping to ask on every one defeats the point of getting out of your way. Decide, then record: append the row to `Landing` with its literal shape and the alternative you rejected, **before the code that closes it is written**, and in that code's commit where the project tracks the artifact. The timing is the mechanism, not the commit. An alternative is only knowable while you are still choosing between them; written at the end of the build it becomes a justification of what you already wrote, which is the stale design document `Landing` exists to avoid. Stating what the other option would have done is also the one thing that can expose a bad decision with nobody else in the loop.

A red proof blocks completion and must be fixed, not merely noted. An expected RED phase in TDD does not interrupt the red → green cycle or require renegotiation. If a check turns out to be wrong or impossible, stop and renegotiate with the user rather than quietly adjusting it. The same goes for a `Landing` row the user approved that the build proves unbuildable - they approved that shape specifically. A new door that contradicts nothing already approved never stops: it gets its row and you keep going.

## Critical rules

1. Every check names its **proof**: the test or command whose exit code settles it. No proof, no check.
2. Tests assert the intended behavior within the approved scope and pre-agreed seams, including edge cases not named in the checklist, never what the code happens to do. Never write a test by reading the implementation.
3. Never weaken an assertion, delete a test, or skip one to make a suite pass. If a test is genuinely wrong, stop and ask.
4. The checks and the test-policy rows do not change while you build: once written they are the bar you build under, not a position to argue against, and lowering either is renegotiation with the user, visible in the diff. `Landing` is the exception, and it is additive - a door you discover while building gets a row, never a deletion.
5. Implementation and its proofs are run by the current session, which does not delegate to other agents. Record the actual command, result, and exit code for every required proof. Do not report the work complete while any required proof is failing or unverified. Independent verification is a separate step, run after this skill by `build-review` on the checklist and diff left here; what this skill owes that step is an honest checklist in the format below and the final commit range accessible. Completion reported here is the session's own account, not independent review.
6. **Blast radius:** an approved checklist authorises local edits and local commits. `git push`, deploy and production data changes need an explicit go-ahead.

## When NOT to be lazy

Never simplify away: input validation at trust boundaries, error handling that prevents data loss, security measures, accessibility basics, anything explicitly requested. User insists on the full version → build it, no re-arguing.

Never lazy about understanding the problem. The ladder shortens the solution, never the reading. Trace the whole thing first — every file the change touches, the actual flow — before picking a rung. Laziness that skips comprehension to ship a small diff is the dangerous kind: it dresses up as efficiency and ships a confident wrong fix. Read fully, then be lazy.

Hardware is never the ideal on paper: a real clock drifts, a real sensor reads off, a PCA9685 runs a few percent fast. Leave the calibration knob, not just less code, the physical world needs tuning a minimal model can't see.

Lazy code without its check is unfinished. Non-trivial logic (a branch, a loop, a parser, a money/security path) leaves at least one runnable check behind, the smallest thing that fails if the logic breaks: an `assert`-based `demo()`/`__main__` self-check or one small `test_*.py`. Reuse the repo's existing test setup and the commands that already run in CI; do not add a new framework or extra fixtures beyond what that setup needs, unless asked. Trivial one-liners need no test, YAGNI applies to tests too.

## Required references

Before implementing, read [Checklist](references/checklist.md). Reuse the existing issue-specific checklist when there is one; otherwise write it from the approved source before any code. When the source comes from `$spec-plan`, use `.checks/<plan-id>-<issue-key>-<slug>.md`; for other sources, keep the checklist naming appropriate to that source. Confirm any test seam not already approved before writing tests at it.

Before the final response, read [Final report](references/relatorio.md). Report only the observed implementation state and the actual results this session obtained. State implementation status and independent-review status separately: local proofs run and passed here, `build-review` still pending.

## Próximo passo (fluxo)

Fluxo: `/spec-plan` → **`/implementar`** (você está aqui) → `/build-review`.

`/implementar` é uma das duas formas de construir uma spec: aqui quem constrói é o **próprio Claude**. A alternativa é `/gpt-builder`, em que um **subagente GPT (Codex)** constrói com acesso total e o Claude revisa o diff — use aquela quando quiser delegar a construção ao GPT. As duas ocupam o mesmo lugar no fluxo e entregam o mesmo par (checklist + diff) para o `/build-review`.

Terminada a construção, ofereça `/build-review` (opcional, só com o OK do usuário): 3 revisores independentes sobre o diff + a checklist exclusiva da issue (`.checks/<plan-id>-<issue-key>-<slug>.md`, ou o caminho de checklist apropriado quando a fonte não vem do `/spec-plan`).
