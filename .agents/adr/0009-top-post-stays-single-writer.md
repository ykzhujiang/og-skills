# The top post stays single-writer, on the strength of edit history

The top post is rewritten in full by whichever run happens last, including in a thread with several participants. Two alternatives were proposed and both were rejected.

## The problem this accepts

Whoever runs last holds the power to restate everyone's position in the shared current state. Three consequences, all real:

- **An agent's compression favours its own side.** The thread's own standing `Disagreement` entry already records this risk: an AI writing the summary can sound impartial while quietly flattering its own case, which is harder to catch than open partisanship.
- **The other party gets no review window** — their position is rewritten and live before they see it.
- **The rewrite is silent.** Nobody is notified that their words were re-expressed.

## Option rejected 1 — require consensus before the top post may be updated

Proposed by the repo owner, and rejected after argument, for reasons that outweigh the problem it solves:

**It deadlocks.** The common case in asynchronous work is not disagreement but **no reply**. Under a consensus rule one silent participant freezes the top post indefinitely, and the thread advertises a state weeks out of date. A stale state is more dangerous than a contested one, because it looks intact.

**`Disagreement` could never land.** That section exists precisely to carry what has *not* been agreed. A rule admitting only consensus excludes, by construction, the one section a reader most needs.

**It is unenforceable.** GitHub offers no such lock: `UpdateDiscussionInput` accepts only `discussionId`, `title`, `body`, `categoryId` — no version, no ETag (schema introspection, [ADR 0002](./0002-lasteditedat-not-updatedat.md)). Everyone has a comment box and a web editor. This repeats the reasoning that already rejected "everyone must go through an AI": robustness belongs in code, not in people remembering.

## Option rejected 2 — per-person ownership of the position sections

Split the top post so `Verified facts` / `Still open` / `Ruled out` stay freely rewritable, while `Settled` and `Disagreement` are partitioned per participant, each block writable only by its holder — plus a line in every session comment declaring which sections were touched and whether any belonged to someone else.

This makes misrepresentation *structurally* impossible rather than merely forbidden, which is a genuine gain. Rejected as disproportionate: it lengthens the top post, needs a signature convention, and mainly duplicates protection that already exists as rules — dissent verbatim, never remove another's open question, `Settled` holds only what a human endorsed.

## Decision

Keep the single-writer top post, because **the rewrite is recoverable**. Measured on `opengrove-discuss-test` #7, 2026-08-22:

```
userContentEdits(first:10) on the Discussion
  totalCount: 2
  2026-08-21T18:05:22Z  ykzhujiang  diff present, 11,705 chars
  2026-08-21T15:26:40Z  ykzhujiang  diff present,  8,881 chars
```

GitHub retains the **full prior body** of every top-post edit, so an unfair rewrite can be shown and reverted. Nothing is destroyed; the exposure is a delay before it is noticed.

## The residual risk, recorded because it was not eliminated

**Recoverability is not notification.** The history exists and nobody reads it. The failure mode this decision keeps is therefore: a position is restated, the restatement is live and unremarked, and it is corrected only if someone independently goes looking. Cheapest available mitigation, not adopted: one line per session comment naming which sections were rewritten.

Both alternatives remain available if multi-party use produces a real incident — none has occurred, because multi-party remains untested ([TESTING.md](../../TESTING.md)). The decision is reversible in a way the deadlock it avoids would not have been.
