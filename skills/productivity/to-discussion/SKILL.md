---
name: to-discussion
description: Publish the current discussion state to GitHub Discussions — creating the thread on first run, appending a session comment and refreshing the top post on later runs. Threads are matched by slug. Use after or during a grilling session.
---

# To Discussion

Publish the state of the current conversation to the repo's GitHub Discussions, so a later session, a teammate, or a teammate's agent can pick it up without anyone re-explaining.

**Online is the source of truth.** Code is versioned locally; collaboration state is queried live. Never write a local snapshot of a discussion and never trust a stale one — read the thread before every write.

## When to run

Run when the user signals they are done for now: "no further ideas for now", "let's stop here", or an explicit wrap-up. **The signal is theirs.** Do not wait for the frontier to be empty — an unfinished frontier is the normal case and becomes `Still open`.

## Step 1 — Config

Config is local (it is configuration, not state). Read `docs/agents/discussion-config.md`. If absent, create it on this run.

```markdown
# Discussion config
repo: ykzhujiang/opengrove-discuss-test
category_id: DIC_xxx
category_name: Ideas
slug_prefix_format: "[<slug>]"
```

### Which repo the thread goes in

Resolve `repo` in this order, and **stop at the first hit**:

1. A repo the user named in this conversation.
2. `repo:` in the config file.
3. The **home repo** default: `ykzhujiang/opengrove-discuss-test`.

The home repo wins over the repo you happen to be working in. That is deliberate: thinking crosses repos and often predates any of them, so discussions collect in one place instead of scattering across every checkout that happened to be open at the time. A thread about which database to use should not be stranded in whichever service repo the conversation started in.

**Say which repo you used, in one line, every run.** A default that writes somewhere the user did not expect, silently, is worse than asking. One line — `→ ykzhujiang/opengrove-discuss-test #12` — is enough; do not turn it into a question.

> **Other people installing this skill:** the home repo above is the author's and is private to them. Change the `repo:` line in your config, or name your own repo in conversation, on first use. Until you do, runs will fail on permissions.

To fill it, resolve the repo and its categories in one call:

```bash
gh api graphql -f query='
query($owner:String!,$name:String!){
  repository(owner:$owner,name:$name){
    id
    hasDiscussionsEnabled
    discussionCategories(first:25){ nodes{ id name slug isAnswerable } }
  }
}' -F owner=OWNER -F name=NAME
```

- Not a GitHub repo → **stop**. There is no local fallback.
- `hasDiscussionsEnabled: false` → **stop**. Tell the user to enable **Settings → General → Features → Discussions**, then re-run. Attempt no workaround.
- Propose a category (prefer a non-answerable one such as Ideas or General), **confirm it with the user once**, then write the config.

## Step 2 — Slug

Every thread is identified by a slug carried in its title:

```
[<slug>] <human-readable title>
```

- Lowercase, hyphenated, 2–4 words: `multi-party-approval`, `discussion-storage`.
- **A slug is permanent.** Never rename one; a renamed slug orphans its thread.
- On a new topic, propose a slug and **have the user confirm it** before creating anything.

Find the thread by exact slug prefix:

```bash
gh api graphql -f query='
query($owner:String!,$name:String!,$cat:ID!){
  repository(owner:$owner,name:$name){
    discussions(first:100,categoryId:$cat,orderBy:{field:UPDATED_AT,direction:DESC}){
      nodes{ id number title url updatedAt lastEditedAt }
    }
  }
}' -F owner=OWNER -F name=NAME -F cat=CATEGORY_ID
```

Match `[<slug>]` as a literal prefix — **do not** fall back to fuzzy matching on wording. Two outcomes only:

- **Exact slug hit** → this is the thread. Append to it.
- **No hit** → new topic. Confirm the slug, then create.

If the topic looks like an existing thread under a *different* slug, show the user both and let them decide. Never merge threads on your own judgement.

## Step 3 — Participants (required)

**The GitHub author field is unreliable** — a shared bot token makes every thread look like one person. So every session comment must name its real participants.

Ask once per session, in one exchange: who took part. Record them in the session comment header — `**S3** · 2026-08-20 · 朱江、小习`. **A session comment without names is invalid** — ask rather than guess, and never infer names from git config.

Names sit in the header rather than folded away because "who was in the room" is what a reader checks first when deciding whether a session concerns them.

## Step 4 — Write

Order matters: **comment first, top post second.** The comment is this session's permanent record; if the top-post update is later blocked by a conflict, the session is still safely captured.

### First run on a slug — create

```bash
gh api graphql -f query='
mutation($repo:ID!,$cat:ID!,$title:String!,$body:String!){
  createDiscussion(input:{repositoryId:$repo,categoryId:$cat,title:$title,body:$body}){
    discussion{ id number url }
  }
}' -F repo=REPO_ID -F cat=CATEGORY_ID -F title="[slug] Title" -F body=@body.md
```

Then **post the Session 1 comment too**, using the same format as any later session:

```bash
gh api graphql -f query='
mutation($d:ID!,$body:String!){
  addDiscussionComment(input:{discussionId:$d,body:$body}){ comment{ url } }
}' -F d=NEW_DISCUSSION_ID -F body=@session1.md
```

Creation is a session like any other. Skipping its comment breaks the *one session = one comment* invariant that state rebuild depends on — see the rebuild table below.

### Later runs — append, verify, then refresh

```bash
# 4a. Append this session. Never edit an existing comment.
gh api graphql -f query='
mutation($d:ID!,$body:String!){
  addDiscussionComment(input:{discussionId:$d,body:$body}){ comment{ url } }
}' -F d=DISCUSSION_ID -F body=@increment.md
```

**4b. Concurrency check — do this between the two writes.** Re-read the thread and compare **`lastEditedAt`** against the value you read in Step 2:

```bash
gh api graphql -f query='
query($id:ID!){ node(id:$id){ ... on Discussion { lastEditedAt updatedAt body } } }
' -F id=DISCUSSION_ID
```

**Compare `lastEditedAt`, never `updatedAt`.** Verified behaviour of the two fields:

| action | `updatedAt` | `lastEditedAt` |
|---|---|---|
| someone adds a comment (incl. **your own** in 4a) | bumped | unchanged |
| someone edits the top post body/title | bumped | bumped |

Because Step 4a posts your comment *before* this check, `updatedAt` has **always** moved by the time you get here — comparing it fires on every single run. `lastEditedAt` moves only when the top post itself is edited, which is exactly the collision you care about.

`lastEditedAt` is **`null` until the post is first edited**. Treat `null → null` as unchanged; treat `null → timestamp` and any timestamp change as a collision.

`lastEditedAt` differs → **someone else wrote while you were working. Stop before touching the top post.** Show the user what changed and ask whether to merge their content in, overwrite, or leave the top post alone. **Never silently overwrite.**

> GitHub offers no optimistic lock here: `UpdateDiscussionInput` accepts only `discussionId`, `title`, `body`, `categoryId` — there is no version or ETag field. This re-read is the only available guard, and it narrows the race rather than closing it.

```bash
# 4c. Rewrite the top post to the current picture.
gh api graphql -f query='
mutation($d:ID!,$body:String!){
  updateDiscussion(input:{discussionId:$d,body:$body}){ discussion{ url } }
}' -F d=DISCUSSION_ID -F body=@body.md
```

Always pass bodies with `-F name=@file`. Never inline a multi-line body into a query string.

## Division of labour

| | Holds | Mutability |
|---|---|---|
| **Top post** | The current picture only | Rewritten every run |
| **Comments** | One per session: what changed | **Append-only, never edited** |

Current state comes from the top post; the path it took comes from the comments. Never restate comment history in the top post.

## Who reads what

A thread is read by two audiences with opposite needs. A human scanning it wants to know in seconds whether it concerns them. You want everything. Writing one document that serves both produces a wall of text the human stops opening — at which point the thread has failed, however complete it is.

Split it across **three tiers**, exploiting the fact that you read raw markdown and the human reads rendered HTML:

| tier | written as | human sees | you see |
|---|---|---|---|
| **Headline** | plain text at the top | yes — this is all they read by default | yes |
| **Detail** | `<details>` block | collapsed; one click if they want it | yes, always |
| **Machine state** | `<!-- ... -->` | nothing | yes |

**Every headline is one tweet: 280 characters, hard limit.** Not a paragraph trimmed — one sentence that survives on its own. If it will not fit, the thing you are trying to say is two things.

Nothing is *lost* to the fold: `<details>` is a display default, not a deletion. Everything you would have written still gets written, one tier down.

## Top post format

```markdown
<!-- agent-state
schema: opengrove.discussion.v1
slug: multi-party-approval
status: exploring          # exploring | settled | superseded
open_questions: 3
sessions: 2
last_session: 2026-08-20
participants_all: [朱江, 王工]
supersedes:
promoted_decisions: []
-->

# [multi-party-approval] 多人批准与推翻规则

**Now:** <one tweet: where this stands and why it matters now.>
**Needs you:** <the single thing waiting on this reader — or `nothing`.>

## Still open

1. <Question> — not yet discussed
2. <Question> — blocked on: <person>
3. <Question> — deferred: <why>

<details>
<summary><b>Settled</b> — 6</summary>

1. <Conclusion> — because <reason>.

</details>

<details>
<summary><b>Ruled out</b> — 4</summary>

1. <Option> — rejected because <reason>.

</details>

<details>
<summary><b>Disagreement</b> — 朱江 dissents on Settled 5</summary>

**朱江:** <their position, their words, untouched.>

</details>
```

`Now` and `Needs you` are the whole human-facing contract: where it stands, and whether it is their turn. **`Still open` stays unfolded** — it is short, and it is the only section that asks anything of anybody. `Settled` and `Ruled out` fold: they only grow, and they are lookup material, consulted rather than read.

**`Disagreement` folds, but its `<summary>` must name who dissents and what they dissent from.** That line is a pointer, **not a summary of their argument** — a human must be able to see that dissent exists without opening it, and must get the position itself verbatim when they do. Compressing someone's objection into the summary line is the one compression that is forbidden here.

## Session comment format

```markdown
**S3** · 2026-08-20 · 朱江、小习

<one tweet: what this round changed. Not what it discussed — what changed.>

<details>
<summary>detail</summary>

**Covered:** what this round went after.

**Settled this session:** new conclusions, with reasons.

**Opened this session:** questions this round surfaced.

**Unresolved:** what was tried and left open.

</details>
```

Two visible lines per session. A human scrolling the thread reads the stream of tweets and gets the shape of how the thinking moved; they open a session only when one of them matters to them.

The tweet reports **change, not activity**. "Discussed the permission model" tells a reader nothing. "Went single-owner; dissent stays on record. Now stuck on whether an owner can be overruled." tells them where things went and what is live.

**If the `agent-state` block is missing or unparseable** (a human editing the post on the web may delete it), rebuild it from the body and the thread metadata, then say so in your report. Never fail the run over it. Derive each field from an observable signal:

| field | rebuild from |
|---|---|
| `slug` | the `[...]` prefix of the title |
| `sessions` | number of comments whose first line matches `**S<N>** ·` |
| `last_session` | date of the newest session comment |
| `participants_all` | union of the names in every `**S<N>** · <date> · <names>` header |
| `open_questions` | number of items under `## Still open` |
| `status` | `promoted_decisions` empty and open items remain ⇒ `exploring` |

**This is why session 1 must also post a session comment** (Step 4a runs on creation too, not just on later sessions). If creation writes only the top post, the invariant *one session = one comment* breaks, and a rebuild counts `sessions` one too low with no way to detect the error — the state silently disagrees with reality. Keep the invariant exact and the rebuild needs no correction factor.

## Rules

- **Record the unasked.** An unreached frontier branch is a finding, not an omission. An empty `Still open` almost always means you failed to record something.
- **Never invent settlement.** Only what the user confirmed is `Settled`. Your unanswered recommendation is an open question.
- **Reasons, not just conclusions.** A conclusion without its reason cannot be applied to a case nobody discussed.
- **Attribute by name.** Participants on every session comment; names on every disagreement position.
- **Keep disagreement raw.** Preserve wording. Synthesising destroys the signal.
- **One slug, one thread.** Forever.
- **No local snapshot** of a discussion. Two copies drift.
- **Do not promote to a decision here.** Turning a settled item into an ADR has its own gates and belongs elsewhere.

## Report back

Print: thread URL, created-or-appended, slug, category, counts of settled and open items, participants recorded, and whether a concurrency conflict or a rebuilt state block was encountered. On a failed precondition, print only what to fix.
