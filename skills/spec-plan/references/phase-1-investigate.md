Phase 1 — Investigate

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask *now* without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Simplicity

1. When considering solutions, prefer the simplest one that fully satisfies the agreed behavior:
2. Avoid speculative functionality, abstractions, and scaffolding.
3. Reuse existing code, patterns, platform capabilities, and installed dependencies when appropriate.
4. Introduce new architecture or dependencies only when simpler existing options do not satisfy the requirements.
5. For bug fixes, address the root cause rather than only the reported symptom.
6. Challenge unnecessary complexity when it appears, but leave decisions to the user.

Simplicity must never remove required behavior, input validation at trust boundaries, error handling needed to prevent data loss, security requirements, accessibility basics, or anything explicitly agreed with the user.

Format a round like so:

📝 **1** - **<question title>**: <question body, might be multiple paragraphs, including 3 multiple choices A, B, C>

 <✅ your recommended answer>

📝**2** - **<question title>**: <question body, might be multiple paragraphs, including 3 multiple choices>
 <✅ your recommended answer A, B, C>

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round, not this one.

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment, repository, tools, or other available sources, find it yourself; don't ask the user for anything you could look up once access is available. Don't block on it: an unresolved fact is an unsettled prerequisite, so only the questions downstream of it wait; ask the rest of the frontier now. The decisions are the user's: put each to them and wait.

The nine nobody writes down

Before asking for confirmation, run one round on the requirements that never make it into a request. For each of the nine, say where it lands: a decision already settled above, a new question in this round with your recommended answer, or "out of scope because X" for the user to confirm. All three are complete answers; passing over one in silence is not.

1. input validation
2. failure modes (what happens when it goes wrong)
3. idempotency and retry (repeating the same action does not duplicate)
4. authorization (who may)
5. concurrency and ordering
6. data lifecycle (creation, retention, removal)
7. external dependency failure
8. state transitions
9. observability (log, metric)

Raising one is always free; growing the scope is the user's call. Asking now, while the user is in the conversation, is what keeps the build from stopping later to ask.

The design investigation is done when every branch required to define the agreed scope has been visited, all required decisions are settled, and each of the nine has landed.

If the user said the planning depends on an existing repository, any branch that depends on repository facts must also be resolved before the investigation is complete.
If the user said the planning does not depend on a repository, repository access is not required to complete the investigation.

Do not create branches for speculative functionality outside the agreed scope.
Do not proceed until the user confirms you have reached a shared understanding.
Once confirmed, continue directly to Phase 2 — Spec. Do not implement the feature.

