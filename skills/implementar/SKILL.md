---
name: implementar
description: Use when the user invokes /implementar, $implementar or @implementar, or says yes to the hand-off offered by /spec-plan, to build work already decided in a spec, plan, tickets or issue of the current repository. Not for deciding what to build.
---

# Implementar

Implement the work described by the user in the spec or tickets.

## Clean tree first

Before anything else, run `git status --porcelain`. Every path it lists must be inside the plan directory of `SPEC_FILE` or inside `.checks/`. Any other path is someone's unfinished work sitting in the tree: stop and ask the user to commit it or set it aside. Work started on top of loose changes cannot be told apart from them later - the start marker only fences what is committed, and `$build-review` would review those changes as if they belonged to this task.

With the tree clean and nothing staged, make the start marker right away, before writing the checklist: `git commit --allow-empty -m "chore(checks): start <checklist file name, without .md>"`. It carries no code; it is the stake that says where the work began - `$build-review` finds it by that message and reviews everything after it. Right after the marker, run the full test suite once and record the result in the checklist's `Suite before start` line. A test already failing there goes to the final report as pre-existing; the recorded line is what proves it, so nothing has to be stashed or checked out later to find out.

## Source contract for spec-plan

When `SPEC_FILE` comes from `$spec-plan`, it must identify exactly one approved issue file under the plan's `issues/` directory.

- Implement only the target issue. Sibling issues and the parent `index.md` are context, not authorization.
- Read the parent index when linked, but do not absorb its other issues into scope.
- If `SPEC_FILE` is an index, a directory, or a document containing multiple implementation issues without one explicit target, stop and ask which issue to implement.
- Use an issue-specific checklist path such as `.checks/<plan-id>-<issue-key>-<slug>.md` so concurrent plans do not share a checklist.
- Preserve the approved issue as the original source for `$build-review`; do not rewrite it during implementation.

When the argument is a plan name, find the plan whose `index.md` declares `Plan name: <that name>`. Zero matches or more than one: stop and ask. In that plan, take the first issue in dependency order that is `approved`, has every blocker finished (`Status: done`), and has no start marker in `git log`. Say which issue you will implement, in one line, and wait for the user's yes before anything else.

With no argument and no hand-off in this conversation, never choose a plan yourself — not the most recent, not the one in the conversation. List the plans that have pending issues, by name, and ask.

Before writing the first test, read [TDD](references/tdd/tdd.md). It is the reference for the red → green loop: what a good test is, where tests go, and the rules of the loop. Use TDD where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end. You decide how. Work the checklist one check at a time: write its test, watch it fail, implement just enough to pass it, run its proof - then the next check. Commit in coherent pieces with Conventional Commits to the current branch, staging each file by name (`git add <path>`) so every commit holds only what that piece changed. The start marker above is the first commit of the work.

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
7. **Each issue starts on its own yes.** Before the start marker of any issue - the first one of the session or the next one after a merge - say which issue, in one line, and wait for the user's yes to that issue. "Merge feito", "ok", or an answer to your own "next I'll start X" closes the current issue; it is not that yes. A plan you announced in an earlier message authorises nothing.

## When NOT to be lazy

Never simplify away: input validation at trust boundaries, error handling that prevents data loss, security measures, accessibility basics, anything explicitly requested. User insists on the full version → build it, no re-arguing.

Never lazy about understanding the problem. Trace the whole thing first — every file the change touches, the actual flow — before writing the fix. Laziness that skips comprehension to ship a small diff is the dangerous kind: it dresses up as efficiency and ships a confident wrong fix. Read fully, then be lazy.

Lazy code without its check is unfinished. Non-trivial logic (a branch, a loop, a parser, a money/security path) leaves at least one runnable check behind, the smallest thing that fails if the logic breaks: an `assert`-based `demo()`/`__main__` self-check or one small `test_*.py`. Reuse the repo's existing test setup and the commands that already run in CI; do not add a new framework or extra fixtures beyond what that setup needs, unless asked. Trivial one-liners need no test, YAGNI applies to tests too.

## Required references

Before implementing, read [Checklist](references/checklist.md). Reuse the existing issue-specific checklist when there is one; otherwise write it from the approved source before any code. When the source comes from `$spec-plan`, use `.checks/<plan-id>-<issue-key>-<slug>.md`; for other sources, keep the checklist naming appropriate to that source. Confirm any test seam not already approved before writing tests at it.

Before the final response, read [Final report](references/relatorio.md). Report only the observed implementation state and the actual results this session obtained. State implementation status and independent-review status separately: local proofs run and passed here, `build-review` still pending.

## Next step (flow)

Flow: `/spec-plan` → **`/implementar`** (you are here) → `/build-review`.

Once the build is complete, `/build-review` is presented (optional, requires user approval): 3 independent reviewers for the diff + a `.checks/<feature>.md` checklist.
