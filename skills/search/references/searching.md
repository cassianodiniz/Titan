# Searching with Exa

You have two tools:
- **`web_search_exa`** -- search by query. Supports `query` and `numResults` params. Use `category:<type>` inline in the query string for category filtering.
- **`web_fetch_exa`** -- read full content from known URLs. Use after search when snippets are insufficient.

Do NOT use `web_search_advanced_exa` or any other Exa tools. Only use these two tools -- do not use Bash, Grep, Read, or Write to process results. Filter and summarize results inline.

## How Exa Search Works

Exa uses vector embeddings, not keywords. It finds pages semantically similar to your query. It does not match keywords exactly, directly understand boolean logic (AND/OR/NOT), or validate that results meet your criteria. You are describing a target page, and Exa returns the nearest neighbors in embedding space.

## Writing Good Queries

**Describe the page you want to find**, not the fact you want to know.

| Looking for | Bad query | Good query |
|---|---|---|
| Blog posts about X | "X" | "detailed blog post about X written by a practitioner" |
| Company doing Y | "Y company" | "category:company startup building Y for enterprise" |
| Person at company | "person at company" | "category:people senior engineer at Acme" |

Write queries as natural grammatical phrases.

**`numResults` sizing -- match to query precision:**

| Query precision | numResults | Example |
|---|---|---|
| Named entity (specific person/company) | 5 | `"WaveForms AI founding story funding details"` |
| Precise filter (narrow category + constraints) | 10 | `"category:company developer tools API testing Series A"` |
| Broad discovery (wide category, few constraints) | 15 | `"category:news engineer launches startup 2025 2026"` |

Never use numResults above 25. If you need more coverage, run more queries with different angles at n=10-15 rather than one query at n=50.

**Use category filters** when searching for a specific entity type. Available inline categories: `company`, `research paper`, `news`, `personal site`, `people`. Add `category:<type>` at the start of your query string.

```
web_search_exa { "query": "category:research paper sparse attention mechanisms for long context", "numResults": 10 }
web_search_exa { "query": "category:people VP Engineering AI infrastructure San Francisco", "numResults": 10 }
web_search_exa { "query": "category:company developer tools for API testing", "numResults": 10 }
```

## Query Diversity

When you need to run multiple queries on the same topic, make sure they target genuinely different angles, not just synonym swaps. "overhyped" vs "overrated" vs "disappointment" are the same angle. A skeptic angle vs a builder angle vs a practitioner angle are genuinely different.

**Word order affects embeddings.** "Python async patterns for web scraping" and "web scraping async patterns in Python" can sometimes return different results. Use this to your advantage when you need coverage -- run 2-3 phrasings in parallel.

## Encoding Time

If your task involves time ("last week", "recent", "this month"), calculate exact dates FIRST from the current date in your environment context. Then encode dates semantically in the query: "published in March 2026" rather than using date filters. Never eyeball dates.

## Searching About LLM Behavior (special rules)

These rules apply whenever the topic is **how a model behaves**: prompting, agents, judges/evals,
context handling, reasoning, benchmarks, or any percentage/threshold about model performance. This
class of finding goes stale faster than the web reflects, and the most-cited result is often the
most obsolete.

**1. Every finding carries two fields, or it does not go in the report:**

| Field | Why |
|---|---|
| **Publication date** | Behavior claims decay. A 2023 finding may describe a model generation that no longer exists |
| **Which model it was measured on** | "Judges approve 80%" measured on GPT-3.5 says nothing about a 2026 judge. This is the field that matters most, and the one most often missing |

A finding whose source states neither is not a finding — report it as *unsourced claim* or drop it.
Missing model is itself signal: it usually marks a blog restating someone else's number.

**The single rule for when to open a page: if the finding carries a number, open the page.**

Not "open it when the date is missing" — always, for any number, percentage, threshold or measured
claim you intend to report. A search snippet that happens to show both the number and a date does
**not** exempt you: you still have not seen whether the sentence around that number says what you
are about to claim, nor who the page credits for it. Snippets are the search engine's excerpt, not
the source.

Once the page is open, everything the record needs is available in the same visit — the verbatim
sentence, the date on the page, what it was measured on, and who the page credits. Nothing here
costs an extra fetch; the fetch is already paid for.

If the page does not state something, write `not stated`. That is a complete answer, not a failure
— report it and move on. Never leave a field out, and never infer a date from the URL, from
surrounding results, or from when the topic was current.

**Report the page you read, and separately who it credits.** Pages routinely attribute a figure to
someone else ("according to X Consulting", "per issue #12345", "as the book reports"). `source_url`
is the page you opened; `credited_origin` is who it credits, as its own field — never buried in the
claim text. A page that credits someone else is a repeat, not a measurement, and two pages
repeating the same original are one source, not two.

**Findings without numbers do not need the fetch.** This rule is about numbers, which travel badly
and are the class that misleads. A qualitative finding, an entity name, a company row in a table —
snippet is enough, as it always was.

**2. Any number or threshold about LLM behavior is a HYPOTHESIS TO TEST, never a confirmed
finding.** Write it as "X predicts Y — measure before acting", not "Y is true". The reader may be
about to change a system based on it; a number transferred from a different model, different
prompt, and different task population is the single most common way research misleads engineering.
This holds even when the source is a strong peer-reviewed paper: the benchmark can be right and the
transfer to the reader's harness still wrong.

**3. Time bounding — encode it in the query, and run a second pass without it.** There is no date
filter available (see the tool restriction at the top of this file), so put the window in the query
text: *"2026"*, *"published in 2026"*, *"replication 2026"*. Then run one query WITHOUT the window,
because canonical work predating it is often still the reference — and cutting it silently is worse
than including it dated. When both passes return the same claim, say whether the recent pass
**replicated** or merely **re-cited** the old one; re-citation is not replication.

**4. Actively search for the refutation.** For any behavior claim you are about to report, run one
query aimed at overturning it — *"X does not replicate"*, *"failed to reproduce X"*, *"X revisited
2026"*. Several widely repeated findings from 2023–24 have been narrowed or overturned; the
original keeps outranking the correction. If you find no refutation attempt, say so — that is
different from having found confirmation.

## Anti-Patterns

- Reporting a behavior percentage without the model it was measured on, or presenting it as fact
  rather than as a hypothesis to test
- Boolean operators ("AND", "NOT") are just words to Exa, not operators
- Quotes don't force exact phrase matching
- Very short queries (1-2 words) produce scattered, low-quality results
- Don't use dates from examples -- always calculate from the current date

## When Searches Return Nothing

If a query returns 0 or only irrelevant results:
a. Make the query longer and more specific
b. Try a different angle, not a synonym swap
c. If multiple angles return nothing, the topic likely has limited web coverage -- report that rather than fabricating results

## Domain-Specific Patterns

If your task involves any of these domains, read the relevant pattern file(s) for specialized query strategies. Pick whichever files match your task — most tasks use 1-2.

| File (same directory as this file) | Domain |
|---|---|
| `patterns-people.md` | People by role, company, location |
| `patterns-companies.md` | Companies by category, stage, competitors, funding |
| `patterns-papers.md` | Academic/research papers |
| `patterns-relationships.md` | Hidden connections (clients, collaborators) |
| `patterns-code.md` | Code, APIs, docs, errors |
| `patterns-news.md` | News, recent events, reactions |

## When `web_fetch_exa` Fails

Fall back to fetching with any other fetch tool you have access to. If that also fails, skip it and work with remaining sources.

## After Getting Results

Exa returns similarity, not validation. You must review titles/snippets and discard irrelevant results using your judgment. Don't assume all results match your criteria. For the most promising results, use `web_fetch_exa` to read the full content.

```
web_fetch_exa {
  "urls": ["https://promising-url-1.com", "https://promising-url-2.com"],
}
```
