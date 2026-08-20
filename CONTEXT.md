# OpenGrove Skills

Agent skills for carrying intent between people, sessions, and agents. A conversation that settled something is an asset; these skills stop it evaporating.

## Language

**Discussion**:
A thinking space with **no commitment attached**. May stay open forever, may never converge. Lives as one GitHub Discussion thread, identified by a **Slug**.
_Avoid_: meeting notes, log, thread (use "thread" only for the GitHub object itself)

**Slug**:
The stable identifier for a **Discussion**, carried as a `[slug]` prefix in the thread title. How a later session finds the thread again. Matched by exact prefix, never by fuzzy title similarity.
_Avoid_: id, key, tag

**Home repo**:
The repo discussions collect in by default, regardless of which repo the agent is working in. Beats the working repo because thinking crosses repos and often predates them. Overridden by `repo:` in config or by the user naming one.
_Avoid_: default repo, central repo, target repo

**Headline**:
The unfolded, human-facing part of a **Top post** or **Session comment** — capped at one tweet (280 characters). The only part a human reads by default. Everything else is folded into `<details>`, present but collapsed.
_Avoid_: summary, TL;DR, abstract

**Top post**:
The first post of the thread. Holds **current state only** and is rewritten every session. Never a history.
_Avoid_: body, description, summary

**Session comment**:
One append-only comment per run, recording what that round changed. Never edited after posting. Exactly one per **Session** — the invariant state rebuild depends on.
_Avoid_: update, entry, log line

**Session**:
One run of the skill against one **Discussion**. Creation counts as session 1.

**Fold**:
A `<details>` block. Detail a human can reach in one click and an agent always reads in full. A fold is a display default, never a deletion — nothing is dropped to make the headline fit.
_Avoid_: collapse, hide, truncate

**agent-state**:
An HTML-comment block at the top of the **Top post** holding machine-readable state (slug, session count, participants, counts). Rebuildable from observable signals if a human deletes it — never load-bearing.
_Avoid_: metadata, frontmatter, header

**Settled / Still open / Ruled out / Disagreement**:
The four standing sections of a **Top post**. `Ruled out` records rejected options *with reasons*; `Disagreement` records dissent **verbatim, unsummarised**.

## Commitment levels

The wider system these skills belong to separates four things by **how much they commit you**. Only the first is implemented here.

- **Discussion** — no commitment. Explore freely.
- **Decision** — commitment. Immutable; superseded, never edited.
- **Spec** — a constraint on an implementation. Mutable within a branch; a transitional artefact whose truth moves into the code.
- **Issue** — an authorisation, with a boundary.

Mixing levels is what makes commitment meaningless: if the thing you committed to can be quietly rewritten, it was never a commitment.

## Relationships

- A **Discussion** has one **Slug**, one **Top post**, and many **Session comments**
- Each **Session** produces exactly one **Session comment**
- A **Top post** contains one **agent-state** block
- A **Discussion** may promote conclusions into **Decisions** (not yet implemented)
