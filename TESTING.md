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
| 5 | `npx skills add ykzhujiang/og-skills --list` discovers all three skills | pass |
| 6 | `scripts/check.sh` passes from a clean clone | pass |

Two real bugs were found and fixed doing this:

- The concurrency guard compared `updatedAt`, which the skill's **own** comment bumps — so it fired on 100% of runs. Now compares `lastEditedAt`, which moves only on top-post edits. ([ADR](./.agents/adr/0002-lasteditedat-not-updatedat.md))
- Creation posted no `Session 1` comment, breaking the *one session = one comment* invariant that state rebuild counts on. A rebuild reported `sessions` one too low **with no signal that it was wrong**. Creation now posts its session comment like any other run.

## Verified (2026-08-22) — the end-to-end path, finally exercised

Run on `ykzhujiang/opengrove-discuss-test`, [thread #7](https://github.com/ykzhujiang/opengrove-discuss-test/discussions/7), by an agent with no prior knowledge of these skills, in opencode, over two sessions.

| # | Behaviour | Result |
|---|---|---|
| 7 | **`grilling` half executed for the first time** — 11 questions over 5 rounds, frontier recomputed each round, downstream questions deferred | pass |
| 8 | `grilling` → `to-discussion` handoff on the user's stop signal | pass |
| 9 | Adjacent-slug judgement: two related threads existed; the run presented both and let the user decide instead of merging | pass |
| 10 | Session 2 on an existing slug: matched by prefix, appended comment, `lastEditedAt` null→null, rewrote top post | pass |
| 11 | Transcript increment against a watermark | **fail — see the bug below** |

**New measurement — top-post rewrites are recoverable.** This is the evidence [ADR 0009](./.agents/adr/0009-top-post-stays-single-writer.md) rests on:

```
userContentEdits(first:10) on a Discussion
  totalCount: 2
  2026-08-21T18:05:22Z  diff present, 11,705 chars
  2026-08-21T15:26:40Z  diff present,  8,881 chars
```

GitHub retains the **full prior body** of every edit, not a patch.

### Third bug found: the watermark was minute-precision

`Covers:` was specified as `2026-08-20T16:43 – 22:19`, and the next increment resumed "after its end time". Turns routinely share a minute, so resuming from `23:22` **pulled four already-published turns back into the second transcript**. Caught before the write only by comparing the new file's first heading against the previous file's last one.

Fixed: the watermark is written to the second, the resume point is queried from the newest turn already recorded rather than parsed from the header, and the heading comparison is now a required check. Same shape as the other two bugs — an assumption that read as obviously correct, failing silently.

### Deviations from `SKILL.md` — the reports worth having

1. **`discuss` could not be invoked at all.** The agent was reached through a chat bridge, where `/discuss` arrives as literal text and no slash command expands. It loaded `grilling` and `to-discussion` by reading their files directly. `disable-model-invocation` also does nothing in opencode (already documented in the README), so the front door is unreachable from a chat surface and the skill only ran because the agent improvised.
2. **`grilling` has no handling for a user who ignores the frontier.** The user redirected instead of answering in 4 of 5 rounds. The skill says to ask the frontier and wait; it does not say what to do when answers never come. The agent invented a ledger of unanswered questions and carried it forward — that worked, but it is not in the instructions, and a different agent would silently drop them.
3. **Step 5 was violated on session 2.** One flagged sensitive item was left unanswered by the user; the agent published anyway on its previously stated default and disclosed that it had done so. `SKILL.md` said only "they answer: go / cut that part / not yet" with no branch for silence. Now specified — see Step 5b.
4. **Config had no `repo:` line.** It resolved via the built-in default, which is fine for one user and not for the shared-repo use this thread settled on. Now called out in Step 1.

## NOT tested — this is where you come in

Be blunt in your report; these are the parts most likely to be broken.

1. **Cold-start path.** Partly exercised now (see the 2026-08-22 table): the agent had no prior knowledge of the skills. But it read the `SKILL.md` files as ordinary files rather than being handed them by the harness, and it could see this repo — so the true cold start, an agent given only the installed skill, is still unproven.
2. **Non-opencode harnesses.** Claude Code and Codex are untried.
3. **Multi-party.** Two humans, or two agents, on one thread concurrently. The guard narrows the race; it does not close it (GitHub exposes no optimistic lock on discussions — `UpdateDiscussionInput` has no version or ETag field). The known-unfixed exposure is written up in [ADR 0009](./.agents/adr/0009-top-post-stays-single-writer.md): a rewrite of someone else's position is recoverable but **not notified**.
4. **Byline omission in the wild.** No mechanical check exists, by decision ([ADR 0010](./.agents/adr/0010-byline-stays-a-convention.md)). Nobody has yet observed a run that forgot it, which is not the same as it not happening.
5. **Slug collisions.** Two different ideas landing on similar slugs.
6. **The closure check (Step 5a).** Added after the run above; the `尚未找到这场讨论要解决的问题` branch has never been produced by a real thread.

## What a useful report says

Where the agent **deviated from `SKILL.md`**, quoting the instruction and what it did instead. An instruction an agent silently declines to follow is a defect in the instruction, not in the agent — those are the reports worth having.

Also worth reporting: any point where the skill **claimed success without doing the thing**. Both bugs above were of that shape.

## Deliberately absent

- **No local snapshot of a thread.** Online is the only source of truth; the thread is read before every write. A cached copy would be a second, staler truth.
- **No offline fallback.** If GitHub is unreachable the run stops. Degrading to a local file would produce exactly the divergence the previous point rules out.
- **No forced terminal state.** A discussion may stay open forever. It is not a meeting record.
