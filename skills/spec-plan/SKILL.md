---
name: spec-plan
description: Use when the user invokes /spec-plan, $spec-plan or @spec-plan to turn an idea or change that is not yet settled into an executable plan. Do not use when the work is already decided, nor to implement, nor when the user is only thinking aloud.
---

# Spec Plan

Turn the idea into approved issues, each self-contained and ready for a separate `$implementar` session.

Follow two phases, in this order. Read each reference only when its phase begins:

1. **Investigate:** read `references/phase-1-investigate.md`. Close scope, decisions and test seams before asking for confirmation of shared understanding.
2. **Plan and slice:** after confirmation, read `references/phase-2-spec.md`. Produce the spec and the issues, present the plan to the user as the phase describes, and wait for approval before writing in the repository or publishing.

Write everything the user may read in the user's language: messages, the parent spec and the issues.

Invariants:

- Never implement the feature.
- Never publish externally without explicit authorization for the exact destination.
- Never use a shared `PLAN.md`. Each plan has its own directory and each issue has a single implementation file.
- The handoff to `$implementar` points to exactly one issue file, never to the index or to the whole directory.
