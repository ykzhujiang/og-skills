# OpenGrove Skills

Agent skills for carrying **intent** between people, sessions, and agents.

A conversation where you figured something out is worth more than the code it produced — and it is the thing we routinely throw away. These skills interrogate a fuzzy idea until it has a shape, then park that shape somewhere a teammate, a later session, or somebody else's agent can pick it up **without anyone re-explaining it**.

> **Status: v0.2.0, lightly proven.** The publish mechanics and — as of 2026-08-22 — the full grill-then-publish path have been exercised against a live repo. Multi-party use has not. Read [TESTING.md](./TESTING.md) before you trust it: it lists what has been exercised, what has not, and the four places an agent deviated from the instructions.

## Install

```bash
npx skills@latest add ykzhujiang/og-skills --skill '*'
```

`--skill '*'` takes **all three**, which is what you want: `discuss` calls the other two, and picking it alone gets you a skill that fails quietly. Drop the flag to choose interactively. Add `-g` for a global install instead of per-project.

Verified: the installer discovers all three skills from this layout.

<details>
<summary><strong>Claude Code plugin</strong></summary>

```
/plugin marketplace add ykzhujiang/og-skills
/plugin install og-skills
```

</details>

<details>
<summary><strong>opencode — read this, one field does not work</strong></summary>

opencode recognises only `name`, `description`, `license`, `compatibility`, and `metadata` in skill frontmatter, and **silently ignores everything else** ([docs](https://opencode.ai/docs/skills/)). The `disable-model-invocation: true` that makes `discuss` human-only in Claude Code therefore **does nothing here**, and the model may fire `discuss` on its own.

The nearest opencode equivalent is a permission rule in `opencode.json`:

```json
{ "permission": { "skill": { "discuss": "ask" } } }
```

`ask` prompts before loading. There is no exact "human-only" setting — this is a real gap, not a workaround we prefer.

</details>

## Where threads go

Discussions collect in a **home repo**, not in whichever repo you happen to be working in — thinking crosses repos and usually predates them ([ADR](./.agents/adr/0005-a-home-repo-for-discussions.md)). Resolution order, first hit wins:

1. a repo you name in conversation
2. `repo:` in `docs/agents/discussion-config.md`
3. the built-in default

**Change the default on first use.** The shipped value is the author's private repo, so until you set your own you will get a permissions error. Either name a repo in conversation, or put one line in `docs/agents/discussion-config.md`:

```markdown
repo: your-org/your-repo
```

That repo needs **Discussions turned on** — Settings → General → Features, or:

```bash
gh api -X PATCH repos/OWNER/REPO -F has_discussions=true
```

Everything else is worked out on the first run and remembered. Every run tells you which repo it wrote to, in one line.

## What lands, and where

Three artefacts with three jobs, and no restating between them:

| artefact | job | mutability |
|---|---|---|
| **Top post** | the current picture, in a neutral voice | rewritten each run |
| **Session comment** | what this round changed, one line + a transcript link | append-only |
| **Transcript** | what was actually said, verbatim | immutable, in git |

Transcripts land under `discussions/<slug>/<date-time>.md` — grouped by **topic**, not by session, because one topic spans many sessions and one session covers many topics. Only the increment is uploaded each time; the watermark sits in the file header.

**Nothing is published without your go-ahead.** The skill shows you the body, the upload range, and anything it judges sensitive — then waits. If you answer about something else and leave a flagged item hanging, it either asks again or acts on the default it already stated **and tells you it did so** — silence is never quietly read as consent.

Before that, it checks **closure**: that what the thread claims to be about and what it concluded are actually a pair. A discussion may start with no question at all — that is deliberate — but it may not be published pretending to answer one.

Every AI-written post carries a `📝 代写` byline, so **a human reply is distinguishable by its absence**. That is a convention rather than a guarantee: the GitHub author field shows whoever's token was used, so it cannot do this job.

## What a thread looks like to read

A human reads roughly **a third** of a thread by default, and loses access to none of it.

The unfolded part is `Now` (where this stands), `Needs you` (whether it is your turn), and `Still open`. `Settled`, `Ruled out`, and `Disagreement` sit in `<details>` — one click away, always read in full by the agent. Headlines are capped at **one tweet, 280 characters**.

The split exploits the fact that agents read raw markdown while humans read rendered HTML, so there is no duplication and no second source of truth. Measured on a live thread: 358 characters visible, 807 folded. Reasoning in [ADR 0004](./.agents/adr/0004-split-what-humans-read-from-what-agents-read.md).

`Disagreement` folds, but its summary line names **who** dissents and **what from**. Compressing the objection itself is the one compression the skill forbids.

## The skills

### User-invoked

- **[discuss](./skills/productivity/discuss/SKILL.md)** — grill an idea into shape, then publish it. The front door; the other two do the work. Also holds the overrides on `grilling` that cannot live in `grilling` itself because it is vendored: ungated starting point, no root-cause digging, two-tier replies, and hand the user the links when it lands.

### Model-invoked

- **[to-discussion](./skills/productivity/to-discussion/SKILL.md)** — publish the current thinking to GitHub Discussions. Creates the thread on first run; on later runs appends a session comment and rewrites the top post. Threads are matched by slug.
- **[grilling](./skills/vendor/grilling/SKILL.md)** — relentless round-by-round interview. **Vendored from [mattpocock/skills](https://github.com/mattpocock/skills), MIT, © Matt Pocock** — see [ATTRIBUTION.md](./skills/vendor/grilling/ATTRIBUTION.md).

## The shape it produces

**Top post = current state**, rewritten every session. **Comments = session increments**, append-only. They never repeat each other: the top post tells you where things stand, the comments tell you how they got there.

The top post carries `Settled` / `Still open` / `Ruled out` / `Disagreement`. `Ruled out` and `Disagreement` are the sections that earn their keep — they stop a rejected idea coming back in six months with nobody able to say why it lost.

## Design notes

- [Why GitHub Discussions and not files in the repo](./.agents/adr/0001-discussions-not-repo-files.md)
- [Why the concurrency guard compares `lastEditedAt`](./.agents/adr/0002-lasteditedat-not-updatedat.md)
- [Why `grilling` is vendored](./.agents/adr/0003-vendor-grilling.md)
- [Why the starting point is not gated](./.agents/adr/0007-no-gate-on-the-starting-point.md) — and why the check moved to publish time
- [Why there is no digging for a root problem](./.agents/adr/0008-no-single-root-problem.md)
- [Why the top post stays single-writer](./.agents/adr/0009-top-post-stays-single-writer.md) — including the option rejected and the risk kept
- [Why the byline has no mechanical check](./.agents/adr/0010-byline-stays-a-convention.md)
- [User-invoked vs model-invoked](./.agents/invocation.md) — convention adapted from Matt Pocock's repo

## Licence

MIT. `skills/vendor/` is third-party — see its own attribution.
