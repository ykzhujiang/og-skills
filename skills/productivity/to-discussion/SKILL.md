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

## Step 4 — Transcript

The post body is written in a neutral voice (see **Voice** below). That voice is only trustworthy because the verbatim exchange sits beside it and can be checked. **Publishing the summary without the transcript is not a lighter version of this skill — it removes the thing that makes the summary auditable.**

**4a. Pull the real dialogue.** Never reconstruct it from memory: a reconstruction wearing the label "transcript" is worse than an honest summary. Export the actual session, keep only the human/assistant text, and drop the machinery.

```bash
sqlite3 "file:$HOME/.local/share/opencode/opencode.db?mode=ro" \
  "SELECT m.time_created, json_extract(m.data,'\$.role'), json_extract(p.data,'\$.text')
   FROM message m JOIN part p ON p.message_id=m.id
   WHERE m.session_id='SESSION_ID' AND json_extract(p.data,'\$.type')='text'
     AND m.time_created > WATERMARK
   ORDER BY m.time_created, p.time_created;"
```

Locate the session by searching `part.data` for a distinctive phrase from the conversation. Drop `reasoning`, `tool`, `step-start`, `step-finish` — measured on a real session, dialogue was **8.5%** of the record (20,601 of ~245,000 chars) and the rest was machine internals.

**Keep the assistant's mistakes and self-corrections.** They are how the thinking actually formed, and a transcript that quietly launders them is no longer evidence.

**4b. Select by topic — your judgement.** One session covers several topics and one topic spans several sessions; the relation is many-to-many. Choose the exchanges belonging to *this* slug. **Overlap is allowed:** when an exchange bears on two topics, copy it into both topic files. Duplicating a few exchanges costs less than making a reader chase anchors between files, and every topic file must read end-to-end on its own.

**4c. Write it under the topic, not the session.**

```
discussions/<slug>/<YYYY-MM-DD-HHMM>.md
```

Grouped by topic because the topic is what a reader navigates to. The session is recorded in the file header, not the path:

```markdown
# Session transcript — <slug>

- **Covers:** `ses_xxx` 2026-08-20T16:43 – 22:19    ← the watermark
- **Participants:** 朱江（人类）、小习（AI 助手）
- **Thread:** #4
- **Verbatim:** dialogue text only, unedited. Stripped: reasoning 113,952 / tool 93,979 / metadata 13,540 chars.
```

`Covers` **is** the watermark, and it lives in the file rather than in `agent-state` so that it travels with the thing it describes and survives anyone editing the thread. For the next increment, find the newest file in this topic folder **for the same session** and resume after its end time. A different session starts fresh.

**No index file in the topic folder.** The thread is already the index — every session comment links its own transcript, in order. A second listing would only drift.

## Step 5 — Confirm before landing

**Never publish unprompted.** A faithful record is not automatically something the user wants colleagues to read.

Show the user three things and wait:

1. The post body you intend to publish (short — they will actually read it).
2. The upload range: `08-20 16:43–22:19, 24 exchanges, ~20.6KB`.
3. **Anything you judge sensitive, called out by you.** You cannot know what carries a political cost for them, but you can flag what reads badly: negative metrics, criticism of a named person, an unflattering number, a half-formed opinion they may not want on record.

They answer: go / cut that part / not yet. Point 3 is the one that earns this step — a gate the user has to police themselves is a gate that fails.

## Step 6 — Write

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
# 6a. Append this session. Never edit an existing comment.
gh api graphql -f query='
mutation($d:ID!,$body:String!){
  addDiscussionComment(input:{discussionId:$d,body:$body}){ comment{ url } }
}' -F d=DISCUSSION_ID -F body=@increment.md
```

**6b. Concurrency check — do this between the two writes.** Re-read the thread and compare **`lastEditedAt`** against the value you read in Step 2:

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

Because Step 6a posts your comment *before* this check, `updatedAt` has **always** moved by the time you get here — comparing it fires on every single run. `lastEditedAt` moves only when the top post itself is edited, which is exactly the collision you care about.

`lastEditedAt` is **`null` until the post is first edited**. Treat `null → null` as unchanged; treat `null → timestamp` and any timestamp change as a collision.

`lastEditedAt` differs → **someone else wrote while you were working. Stop before touching the top post.** Show the user what changed and ask whether to merge their content in, overwrite, or leave the top post alone. **Never silently overwrite.**

> GitHub offers no optimistic lock here: `UpdateDiscussionInput` accepts only `discussionId`, `title`, `body`, `categoryId` — there is no version or ETag field. This re-read is the only available guard, and it narrows the race rather than closing it.

```bash
# 6c. Rewrite the top post to the current picture.
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

## Voice

**Write the body as an outside observer describing a discussion between people and an AI** — not as the AI addressing a reader, and not as the human's own notes.

```
讨论中朱江主张「AI 是助手、主体是人」，小习指出该表述回答的是归属问题
而非机制问题；朱江认可后请小习给出方案。
```

One sentence carries who proposed what, who objected, and how it resolved. This is why the body needs no per-item author tags: **the neutral voice puts attribution inside the prose**, where a tag would have to be bolted onto the format.

The pairing to hold onto:

| | says |
|---|---|
| the `AI 代写` byline | **who typed it** |
| the neutral voice | **whose thinking it is** |

### The trap in this, stated plainly

**The one writing the neutral account is the AI itself.** Choosing how to characterise your own position and the human's is an editorial act, and it is entirely possible to sound impartial while quietly making your own case look better. That failure is *harder* to catch than obvious partisanship.

Neutral voice is safe under exactly one condition: **the verbatim transcript sits beside it, so any characterisation can be checked.** This is the reason Step 4 is not optional.

### Byline

Every top post and every session comment the AI writes opens with:

```markdown
> 📝 本帖由 <AI 名> 代写。逐字对话见文末链接。
```

The whole post is marked, not individual lines. The point is not modesty — it is that **a human replying in the thread is then distinguishable by the absence of the byline**, with no extra machinery.

`agent-state` cannot do this job: it is an HTML comment, so a human reading the rendered page never sees it. The byline must be visible text.

**This is a convention, not a guarantee.** A run that forgets the byline silently passes AI text off as human. A separate GitHub identity for the AI would make it structural rather than disciplined; it is not built, and adding it later does not invalidate the byline.

## Top post format

```markdown
<!-- agent-state
schema: opengrove.discussion.v2
slug: multi-party-approval
-->

# [multi-party-approval] 多人批准与推翻规则

> 📝 本帖由小习（AI）代写。逐字对话见各 session 评论中的链接。

**Now:** <one tweet, neutral voice: what this discussion has reached and why it matters now.>
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
<summary><b>Verified facts</b> — 8</summary>

1. <What was measured, and the number.> — measured <when/how>.

</details>

<details>
<summary><b>Disagreement</b> — 朱江 dissents on Settled 5</summary>

**朱江:** <their position, their words, untouched.>

</details>
```

### Why this block holds only two fields

Every other field it used to carry — `status`, `sessions`, `last_session`, `open_questions`, `participants_all`, `supersedes`, `promoted_decisions` — was **written and never read**. Nothing in this skill consulted them to make a decision, and each was either a count of something visible (`open_questions` is just the length of `## Still open`) or state for a feature that does not exist. Recording derived data invites it to disagree with the thing it was derived from.

What survives has a job:

| field | why it exists |
|---|---|
| `schema` | format version, so a later run can tell v1 threads from v2 |
| `slug` | **the only record of the thread's identity if a human renames the title** |

`slug` earns its place because of a measured gap: editing a title produces **no `userContentEdits` history at all** and does not move `lastEditedAt`, so a renamed title leaves no trace of what it used to be. When a slug-prefix search finds nothing, fall back to matching `slug:` inside the body of each thread in the category, and tell the user the title was changed.

**If the block is missing** (a human editing on the web may delete it), recover `slug` from the `[...]` title prefix and carry on — then say so in your report. Never fail a run over it. If the block is gone *and* the title was renamed, the identity is genuinely lost; say that plainly rather than guessing at a match.

`Now` and `Needs you` are the whole human-facing contract: where it stands, and whether it is their turn. **`Still open` stays unfolded** — it is short, and it is the only section that asks anything of anybody. `Settled` and `Ruled out` fold: they only grow, and they are lookup material, consulted rather than read.

**`Verified facts` exists because a measurement is neither a decision nor an open question.** A discussion that touches real systems produces findings — *deleting a comment is irrecoverable*, *dialogue was 8.5% of the session* — that nobody decided and nobody is waiting on. Filing them under `Settled` corrupts that section's meaning, which by rule holds only what a human endorsed. Omit the section when there is nothing measured.

**`Disagreement` folds, but its `<summary>` must name who dissents and what they dissent from.** That line is a pointer, **not a summary of their argument** — a human must be able to see that dissent exists without opening it, and must get the position itself verbatim when they do. Compressing someone's objection into the summary line is the one compression that is forbidden here.

## Session comment format

```markdown
> 📝 本条由小习（AI）代写。

**S3** · 2026-08-20 · 朱江、小习

<one tweet, neutral voice: what this round changed. Not what it discussed — what changed.>

📄 [逐字对话记录](https://github.com/OWNER/REPO/blob/<SHA>/discussions/<slug>/2026-08-20-1643.md) · 20.6KB · 24 轮 · 仅剔除机器内脏
```

Three visible lines. A human scrolling the thread reads the stream of one-liners and gets the shape of how the thinking moved; they open a transcript only when a round matters to them.

**Link with the commit SHA, never a branch name.** A branch link silently changes meaning when the file is appended to; a SHA link is the state that was actually published alongside this comment.

The tweet reports **change, not activity**. "Discussed the permission model" tells a reader nothing. "Went single-owner; dissent stays on record. Now stuck on whether an owner can be overruled." tells them where it went and what is live.

**Do not restate the transcript here, and do not restate the top post.** Three artefacts, three jobs: the top post is the current picture, the comment is what this round changed, the transcript is what was actually said. An earlier version summarised the same conclusions in both the comment and the top post, in *different wording* — which is worse than duplication, because the two then drift and no reader knows which to trust.

## Rules

- **Never publish without the user's go-ahead** (Step 5). Flag what you judge sensitive yourself; a gate the user has to police alone is a gate that fails.
- **Never reconstruct a transcript from memory.** Export it, or do not call it one.
- **Byline every post and comment you write.** A human's reply is identified by the absence of it.
- **Keep your own errors and corrections in the transcript.** Laundering them makes it stop being evidence.
- **Record the unasked.** An unreached frontier branch is a finding, not an omission. An empty `Still open` almost always means you failed to record something.
- **Never invent settlement.** `Settled` holds only what a human explicitly endorsed. Your unanswered recommendation is an open question, not a conclusion.
- **Do not bundle questions.** Six proposals in one breath collect one "sure" and manufacture consent; that failure is fixed here, at the asking, not later by tagging the record.
- **Separate what was measured from what was decided.** A verified fact is neither a conclusion nor an open question; give it its own section rather than diluting `Settled`.
- **Dissent stays in its holder's words.** Do not synthesise a middle ground. The `<summary>` line names who dissents and what from — a pointer, never a précis.
- **Three artefacts, three jobs.** Top post = current picture. Comment = what this round changed. Transcript = what was actually said. No restating across them.
- **Online is the only source of truth for the thread.** Read before every write; never cache it. The transcript is the exception — it is immutable evidence, and git is the right home for that.

## Report back

Print: thread URL, created-or-appended, slug, category, counts of settled and open items, participants recorded, and whether a concurrency conflict or a rebuilt state block was encountered. On a failed precondition, print only what to fix.
