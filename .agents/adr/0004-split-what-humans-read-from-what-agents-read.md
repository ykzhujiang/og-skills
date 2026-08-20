# Split what humans read from what agents read

The first version of the thread format was complete and nobody wanted to open it. A top post carried `Where this stands` plus the full `Settled`, `Still open`, `Ruled out`, and `Disagreement` lists; every session comment carried `Covered`, `Settled this session`, `Opened this session`, and `Unresolved` in full. Measured on a real two-session thread: **1,165 characters**, all of it presented at once.

That is a failure even though nothing in it was wrong. A thread nobody opens has not preserved anything.

## The mistake

Writing one document for two audiences with opposite needs.

An agent picking the thread up wants **everything** — it has no memory of the conversation and cannot infer what was omitted. A human wants to know in **seconds** whether this concerns them, and on most visits the answer is no. Optimising a single body for both lands on the agent's needs, because those are the ones that produce visible loss when unmet. The human's cost is invisible: they just stop reading, and nobody logs that.

## The seam

The two audiences already consume different artefacts. **The agent reads raw markdown over the API; the human reads GitHub's rendered HTML.** Anything inside `<details>` is fully present in the markdown and collapsed in the render. That is a free channel — no duplication, no second source of truth, no sync problem.

Three tiers:

| tier | written as | human | agent |
|---|---|---|---|
| Headline | plain text | reads by default | reads |
| Detail | `<details>` | one click | always reads |
| Machine state | `<!-- ... -->` | never sees | reads |

**Verified** against a live thread: GitHub Discussions renders `<details>`/`<summary>` natively in both the top post and comments, unescaped, via `bodyHTML`. Result on the same thread: **358 characters visible, 807 folded** — a human reads 31% by default and loses access to none of it.

## What stays unfolded, and why

- **`Now` and `Needs you`** — where it stands, and whether it is this reader's turn. One tweet each, 280 characters hard.
- **`Still open`** — short, and the only section that asks anything of anybody.
- **`Settled` / `Ruled out`** — folded. They only grow, and they are consulted, not read.
- **`Disagreement`** — folded, but the `<summary>` must name **who** dissents and **what from**.

That last one is the constraint worth stating explicitly: the summary line is a **pointer, not a précis**. A reader must see that dissent exists without opening it, and get the position verbatim when they do. Compressing someone's objection into the summary is the one compression forbidden here — it is the exact failure the `Disagreement` section exists to prevent, reintroduced through the back door.

## The rule that makes it work

**One tweet, 280 characters, hard limit** — for the headline and for each session line. Not a paragraph trimmed to fit: one sentence that stands alone. If it will not fit, what you are trying to say is two things, and discovering that is useful.

Session lines report **change, not activity**. "Discussed the permission model" tells a reader nothing. "Went single-owner; dissent stays on record. Now stuck on whether an owner can be overruled." tells them where it went and what is live.

## Known unverified

Whether email and chat notifications flatten `<details>` or drop it. If a notification channel flattens it, the compression is lost in exactly the surface where attention is scarcest.
