# OpenGrove Skills

Agent skills for carrying **intent** between people, sessions, and agents.

A conversation where you figured something out is worth more than the code it produced — and it is the thing we routinely throw away. These skills interrogate a fuzzy idea until it has a shape, then park that shape somewhere a teammate, a later session, or somebody else's agent can pick it up **without anyone re-explaining it**.

> **Status: v0.1.0, unproven.** The publish mechanics are verified against a live repo; the end-to-end path is not. Read [TESTING.md](./TESTING.md) before you trust it — it lists exactly what has been exercised and what has not.

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

## Per-repo setup

The target repo needs **GitHub Discussions turned on** (Settings → General → Features), or via API:

```bash
gh api -X PATCH repos/OWNER/REPO -F has_discussions=true
```

`to-discussion` writes `docs/agents/discussion-config.md` on its first run — it looks the category up, asks you to confirm, then remembers. Nothing to fill in by hand.

## The skills

### User-invoked

- **[discuss](./skills/productivity/discuss/SKILL.md)** — grill an idea into shape, then publish it. The front door; the other two do the work.

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
- [User-invoked vs model-invoked](./.agents/invocation.md) — convention adapted from Matt Pocock's repo

## Licence

MIT. `skills/vendor/` is third-party — see its own attribution.
