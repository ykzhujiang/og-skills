# Testing brief

Read this before reporting. It says what is already known to work, what is known **not** to be tested, and what a useful report contains.

## Verified (against a live repo, 2026-08-20)

Exercised end to end on `ykzhujiang/opengrove-discuss-test`, [thread #1](https://github.com/ykzhujiang/opengrove-discuss-test/discussions/1):

| # | Behaviour | Result |
|---|---|---|
| 1 | First run: look up category, confirm slug, write config, create thread | pass |
| 2 | Second run: match thread by slug prefix, append comment, rewrite top post | pass |
| 3 | Someone else edits the top post mid-run → run stops and asks | pass **after a fix** |
| 4 | `agent-state` block deleted by hand → rebuilt from observable signals | pass **after a fix** |

Two real bugs were found and fixed doing this:

- The concurrency guard compared `updatedAt`, which the skill's **own** comment bumps — so it fired on 100% of runs. Now compares `lastEditedAt`, which moves only on top-post edits. ([ADR](./.agents/adr/0002-lasteditedat-not-updatedat.md))
- Creation posted no `Session 1` comment, breaking the *one session = one comment* invariant that state rebuild counts on. A rebuild reported `sessions` one too low **with no signal that it was wrong**. Creation now posts its session comment like any other run.

## NOT tested — this is where you come in

Be blunt in your report; these are the parts most likely to be broken.

1. **`grilling` → `to-discussion` handoff.** Only the publish half was ever run. The grill half has never executed. The whole premise is "interrogate, then publish" and the interrogate step is unproven.
2. **Cold-start path.** Verification was performed by the author executing the GraphQL by hand, already knowing the design. Whether a fresh agent given only `SKILL.md` follows it correctly is **untested** — and it is the only path that matters.
3. **Non-opencode harnesses.** Claude Code and Codex are untried.
4. **Multi-party.** Two humans, or two agents, on one thread concurrently. The guard narrows the race; it does not close it (GitHub exposes no optimistic lock on discussions — `UpdateDiscussionInput` has no version or ETag field).
5. **Slug collisions.** Two different ideas landing on similar slugs.

## What a useful report says

Where the agent **deviated from `SKILL.md`**, quoting the instruction and what it did instead. An instruction an agent silently declines to follow is a defect in the instruction, not in the agent — those are the reports worth having.

Also worth reporting: any point where the skill **claimed success without doing the thing**. Both bugs above were of that shape.

## Deliberately absent

- **No local snapshot of a thread.** Online is the only source of truth; the thread is read before every write. A cached copy would be a second, staler truth.
- **No offline fallback.** If GitHub is unreachable the run stops. Degrading to a local file would produce exactly the divergence the previous point rules out.
- **No forced terminal state.** A discussion may stay open forever. It is not a meeting record.
