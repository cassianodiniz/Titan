Phase 2 — Spec
Take the current conversation context and available codebase understanding and produce a spec. The issue tracker and triage label vocabulary should have been provided to you. If not, ask the user for the issue tracker and its triage/label vocabulary before writing the spec. Do not invent project conventions.

Do NOT reopen settled design decisions or repeat questions already answered during investigation. Synthesize what you already know.

If the issue tracker is accessible but the target tracker or ready-for-agent label is not known, ask the user. Do not invent project conventions.
Process

Use the project's domain glossary vocabulary throughout the spec, when available, and respect any ADRs in the area you're touching.

Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations. Explain the proposed seams in plain language when asking for confirmation.

Write the spec using the template below, then publish it to the project issue tracker. Apply the agreed ready-for-agent triage label or equivalent - no need for additional triage.
If the issue tracker is not accessible, return the complete spec to the user and state that publication was not performed.

Problem Statement
The problem that the user is facing, from the user's perspective.

Solution
The solution to the problem, from the user's perspective.

User Stories
A complete, numbered list of distinct user stories. Each user story should be in the format of:
As an , I want a , so that

As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
Cover all user-facing needs relevant to the agreed scope without creating redundant stories.
Behavior Scenarios
Describe the externally observable behaviors required for this spec to be considered correctly implemented.
Use Given / When / Then scenarios.
Cover the important user flows and, when relevant, meaningful edge cases, failure states, permissions, and state transitions.
Do not describe implementation details.
Example:
Mark a response as unread
Given a response is currently marked as read
When the user marks the response as unread
Then the response is shown as unread
And it remains unread after the page is reloaded
Implementation Decisions
A list of implementation decisions that were made. This can include:
The modules that will be built/modified
The interfaces of those modules that will be modified
Technical clarifications from the developer
Architectural decisions
Schema changes
API contracts
Specific interactions
Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.
Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

Testing Decisions
A list of testing decisions that were made. Include:
A description of what makes a good test (only test external behavior, not implementation details)
Which modules will be tested
Prior art for the tests (i.e. similar types of tests in the codebase)
Which Behavior Scenarios the tests are intended to verify
Out of Scope
A description of the things that are out of scope for this spec.

Further Notes
Any further notes about the feature.
