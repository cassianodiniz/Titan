# Extracting Structured Data from Search Results

After running searches, you need to extract structured information from the results. This file covers how to do that well.

## When You Have Enough from Snippets

Exa search results include titles, URLs, and text snippets ("highlights"). For literal entity fields (company name, person name, funding round), the snippet is sufficient. Extract directly from what you have before fetching full pages.

**Except for numbers.** A number, percentage, threshold or measured claim always requires opening the page — see "Findings that carry a number" below, and `searching.md`. A snippet that shows a number is showing you the search engine's excerpt: it does not tell you what the surrounding sentence claims, when the page was published, what the figure was measured on, or whether the page is repeating someone else's figure. Those are exactly the things that decide whether the number transfers, and none of them survive in a highlight.

## When to Deep-Read with web_fetch_exa

Fetch the full page when:
- The finding carries a number (always — see above)
- The snippet mentions what you need but doesn't include the actual value
- You need to read body text to make a judgment call (e.g. "does this blog post show genuine design opinion or is it generic?")
- You need to extract multiple fields from a single rich source (case study page, team page, filing)
- The task requires reading beyond the first few sentences

```
web_fetch_exa {
  "urls": ["https://source-1.com", "https://source-2.com"],
}
```

Batch up to 5-10 URLs per fetch call to minimize round trips. Avoid using `maxCharacters` param or `head`/`tail` bash tools; the point is to understand full page context.

## Extracting into a Schema

When you've been given a schema (the "columns" for the result), extract each field per result:

1. **Structured fields** (name, date, URL, funding amount, ticker): Extract the literal value. If not present, mark as missing rather than guessing.

2. **Categorical fields** (industry, stage, role level): Map to the closest category. Note uncertainty if the mapping is ambiguous.

3. **Semantic fields** (sentiment, whether something qualifies as "genuine opinion", relevance to a theme): Read the content and make a judgment call. Include a brief rationale so downstream synthesis can weigh your assessment.

4. **Negation fields** ("no review mentions X", "no Series A announcement"): These require checking that something is absent. Search for the positive case; if nothing surfaces, report absence with confidence level based on how thorough your coverage was.

## Handling Missing Data

- Mark fields as "not found" rather than guessing or leaving blank
- Distinguish "confirmed absent" (searched thoroughly, not there) from "not found" (didn't have access or coverage was limited)
- If a source is paywalled or inaccessible, note that explicitly

## Confidence Signals

When extracting, note the strength of the evidence:
- **Direct**: The source explicitly states the value (e.g. "We raised $20M in Series B")
- **Inferred**: The value is derived from context (e.g. headcount estimated from team page photos)
- **Uncertain**: Single indirect signal, could be wrong

## Output Format

Return extracted data as compact structured output. For lists of entities:

```
[
  { "name": "...", "field_1": "...", "field_2": "...", "source": "url", "confidence": "direct" },
  ...
]
```

Or as a markdown table if that better suits your task's instructions.

### Findings that carry a number

A number, percentage, threshold, or measured claim is not an entity row — it is something someone
measured somewhere, and it travels badly. **Open the page** (see `searching.md`, "The single rule
for when to open a page"), then return the record below. Field order is deliberate: `notes` is
written first, in plain language, and you fill the typed fields by reading your own notes.

```
{
  "notes": "Three pages carry this number, but two of them credit the same 2023 paper — only the
            first measured anything itself. So this is one measurement with two echoes, not three
            confirmations. The original names the model and year but never says how many cases.",
  "claim": "judge models approve ~80% of cases",
  "support_status": "supports",        // supports | partial | does_not_support
  "measured_model": "GPT-3.5",         // or "not stated"
  "measured_task": "borderline content moderation cases",  // or "not stated"
  "measured_n": "not stated",
  "measured_window": "2023",           // or "not stated"
  "independent_sources": 1,            // origins, not links — see below
  "sources": [
    {
      "url": "https://original-paper…",
      "evidence_quote": "In our runs, the judge approved 80.4% of borderline cases.",
      "credited_origin": "none",       // measured it itself
      "published": "2023-07"
    },
    {
      "url": "https://blog-a…",
      "evidence_quote": "Judges approve around 80% of cases (Smith et al., 2023).",
      "credited_origin": "Smith et al. 2023",   // an echo
      "published": "2026-02"
    },
    {
      "url": "https://blog-b…",
      "evidence_quote": "roughly 80% approval, per Smith et al.",
      "credited_origin": "Smith et al. 2023",   // the same echo
      "published": "not stated"
    }
  ]
}
```

`independent_sources` counts **origins, not links**. Above there are three URLs and one origin: two
of the pages credit the same paper, so they echo it rather than confirm it. Entries with
`credited_origin: none` each count once; entries crediting the same origin collapse into one.

This is what the list is for. Three links can mean three independent measurements or one number
repeated three times, and a report that shows only the links looks identical in both cases.
`independent_sources: 1` beside three URLs tells the reader that the apparent agreement is one
source wearing three hats — which is exactly the mistake this format exists to prevent.

Never merge entries to keep the list short, and never drop one because it says the same thing as
another. Sameness is the signal.

The four `measured_*` fields are separate on purpose. A reader can only judge whether a number
transfers to their situation by comparing all four against it — same model? same task? comparable
number of cases? same period? Collapsed into one field, the mismatch that matters disappears: a
record saying only `"GPT-3.5"` looks documented and still hides that the task was nothing like the
reader's.

`support_status` exists because a page can contain a number without establishing the claim built on
it. Mark `partial` when the quote touches the claim but is narrower or hedged, and
`does_not_support` when the number is there but says something else. That verdict costs nothing —
you already have the page open — and it is the difference between "traceable" and "checked".

Write `not stated` for anything the page does not state. Never omit a field, never leave one blank,
never fill one from the surrounding paragraph or from what you already know. Most real records
carry several `not stated`; that is the honest result, not a failed extraction.

An empty field is the most useful thing you can return: it tells the reader the claim cannot be
checked, which is a finding in itself. A plausible guess destroys exactly that signal.

Keep output compact — but this record is the floor, not verbosity. Compactness is achieved by
dropping prose or dropping whole findings, never by dropping provenance from a finding you keep.
