# to-discussion

## What it does

Publishes the current state of a conversation to GitHub Discussions. First run creates the thread; later runs append a session comment and rewrite the top post.

The split matters: **the top post is state, the comments are history.** The top post answers "where does this stand" and is rewritten each time. The comments answer "how did it get here" and are never edited. They do not repeat each other.

The top post carries `Settled`, `Still open`, `Ruled out`, and `Disagreement`. `Still open` distinguishes *not yet discussed* from *blocked on someone* from *deliberately deferred* — three states usually collapsed into one vague list.

## When to reach for it

Usually not directly — `discuss` calls it. Reach for it on its own when a conversation already produced the thinking and you only need it parked.

## Common questions

**How does it find the right thread?**
Exact `[slug]` prefix match on the title, within the configured category. Never fuzzy matching — a near-miss would append one idea's session onto another idea's thread.

**What happens on a concurrent edit?**
It re-reads `lastEditedAt` between its two writes and stops before touching the top post if it moved. Comments land first on purpose, so the session record is safe even when the top post is blocked. This narrows the race rather than closing it — GitHub exposes no optimistic lock on discussions.

**Someone deleted the `agent-state` comment block. Is it broken?**
No. Every field is rebuilt from observable signals: slug from the title prefix, session count from the comments, participants from the `Participants:` lines. It reports that it rebuilt.

**Does it keep a local copy?**
No, deliberately. Online is the only source of truth; a cache would be a staler second one.

## It's working if

A teammate opens the thread cold and can act on it without asking you a single question — and your dissent is still in there in your own words, not smoothed into consensus.
