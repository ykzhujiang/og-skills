# The concurrency guard compares `lastEditedAt`, not `updatedAt`

`to-discussion` performs two writes per run: append a session comment, then rewrite the top post. Between them it re-reads the thread to check nobody else wrote while it was working. The first implementation of that check was useless in a way that testing exposed immediately.

## The bug

The guard compared `updatedAt` against the value read at the start of the run. But the write order is **comment first, top post second** — deliberately, so that if the top post is blocked by a collision the session record is already safely landed. And a comment addition bumps `updatedAt`.

So the skill's **own** comment moved the field it was about to test. Measured:

```
value recorded at step 2        : 03:07:41Z
re-read after posting own comment: 03:08:13Z   ← moved, with no other party involved
```

The guard reported a collision on **every single run**. The original wording tried to paper over this with "differs (beyond your own comment)" — which is not something an agent can operationally compute from one timestamp.

## The fix

Compare `lastEditedAt`. Verified behaviour:

| action | `updatedAt` | `lastEditedAt` |
|---|---|---|
| a comment is added (including our own) | bumped | **unchanged** |
| the top post body or title is edited | bumped | bumped |

`lastEditedAt` moves only for the event we care about. It is **`null` until the post is first edited**: treat `null → null` as unchanged, and both `null → timestamp` and any timestamp change as a collision.

## What this does not fix

GitHub offers no optimistic lock on discussions: `UpdateDiscussionInput` accepts only `discussionId`, `title`, `body`, and `categoryId` — there is no version or ETag field (confirmed by schema introspection). The re-read **narrows** the race; it cannot close it. A collision landing between the re-read and the update will still be overwritten. Accepted, because comment-first ordering means the irreplaceable part — the session record — is never the thing at risk.

## The general lesson

A guard that cannot fail is indistinguishable from a guard that always fails. This one fired every time and would have been read as "conflicts are common here" rather than "the check is broken". Any state check whose subject is mutated by our own preceding write is suspect by construction.
