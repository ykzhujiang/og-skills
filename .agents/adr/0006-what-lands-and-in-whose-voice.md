# Publish a neutral account plus the verbatim exchange, bylined as ghostwritten

The first version published an AI-written summary to a GitHub Discussion and nothing else. Measured on a real thread, that summary was **99% written by the AI and 100% attributed to the human**, because the GitHub author field shows whoever's token was used. It also restated the top post's conclusions inside the session comment *in different wording*, so the same claim existed twice and could drift.

## What was wrong

Three separate faults, all downstream of treating the AI as the author:

1. **Attribution was false.** A suggestion that appears to come from the person being advised is not a suggestion. The section where the AI recorded its own dissent rendered as the human disagreeing with himself.
2. **`Settled` was mixed.** A conclusion the human reached and one the AI proposed and the human did not object to looked identical — so the record could not answer *whose judgement was this?*
3. **The summary was unfalsifiable.** With no source beside it, a reader had nothing to check it against.

## Decision

**The body is written in a neutral third-person voice**, describing a discussion between people and an AI: who proposed what, who objected, how it resolved. Attribution then lives in the prose, so no per-item author tags are needed — an earlier proposal that this ADR supersedes.

**Every AI-written post and comment carries a visible byline** (`📝 … 代写`). The whole post is marked, not individual lines. A human replying in the thread is then distinguishable by the *absence* of the byline, with no extra machinery. `agent-state` cannot serve here: it is an HTML comment and invisible in the rendered page.

**The verbatim exchange is published alongside**, exported from the session store — never reconstructed. It lands in git under `discussions/<slug>/<date-time>.md`.

**Nothing publishes without the user's go-ahead**, and the AI names what it judges sensitive rather than leaving the user to find it.

## Why the transcript is load-bearing, not supplementary

**The neutral account is written by the AI about itself.** Choosing how to characterise your own position versus the human's is editorial, and it is entirely possible to sound impartial while making your own case look better — a failure *harder* to detect than open partisanship.

The neutral voice is therefore safe under exactly one condition: the verbatim record sits beside it and any characterisation can be checked. Publishing the summary alone is not a lighter version of this skill; it removes the only thing that makes the summary auditable.

A corollary: a transcript the AI writes from memory is worse than an honest summary, because it claims evidentiary status it does not have. Export it or do not call it one. Measured on a real session, dialogue was **8.5%** of the record (20,601 of ~245,000 characters); the remainder was reasoning and tool traffic, which is stripped. The AI's own mistakes and self-corrections are **kept** — laundering them is what would stop it being evidence.

## Grouping by topic, not by session

Topic-to-session is many-to-many: one topic runs across sessions, one session covers several topics. Grouping by topic matches what a reader navigates to. Only the increment uploads each time, and the watermark lives in the transcript file's header rather than in `agent-state`, so it travels with the thing it describes and survives anyone editing the thread.

**Overlap between topic files is allowed.** When an exchange bears on two topics it is copied into both: duplicating a few exchanges costs less than making a reader chase anchors, and every topic file must read end-to-end on its own.

## Known limit

The byline is a convention. A run that forgets it silently passes AI text off as human. A dedicated GitHub identity for the AI would make this structural instead of disciplined; it is not built, and adding it later does not invalidate the byline.
