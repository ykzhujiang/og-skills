# Model-invoked vs user-invoked

> Convention adapted from [mattpocock/skills](https://github.com/mattpocock/skills) `.agents/invocation.md`, © Matt Pocock, MIT.

Every `SKILL.md` is a skill. The axis that splits them is **who can reach it**.

- **User-invoked** — reachable only by a human naming it. Requires **both** `disable-model-invocation: true` in frontmatter (Claude Code) and `policy.allow_implicit_invocation: false` in `agents/openai.yaml` (Codex). The `description` is human-facing: no trigger lists.
- **Model-invoked** — reachable by model or user. Omit both. The `description` is model-facing and keeps rich trigger phrasing so auto-invocation fires.

A user-invoked skill may call model-invoked skills. **It can never reach another user-invoked skill.** In this repo: `discuss` is user-invoked; `grilling` and `to-discussion` are model-invoked, so `discuss` may call both.

## opencode does not honour either field

opencode recognises only `name`, `description`, `license`, `compatibility`, `metadata`, and **ignores unknown frontmatter fields silently**. `disable-model-invocation` has no effect there, so `discuss` is model-reachable on opencode regardless of what the frontmatter says. The closest control is a permission rule in `opencode.json`:

```json
{ "permission": { "skill": { "discuss": "ask" } } }
```

Keep the two frontmatter declarations anyway — they are correct for the harnesses that read them, and being ignored is harmless.

## Expressing dependencies

Name the tool explicitly: `Call the Skill tool with "grilling"`. Not a `../other-skill/FILE.md` cross-reference, not a bare `/skill` mention. The Skill tool takes **one skill per call** — a step needing two is two calls, so say `Call the Skill tool twice, for "grilling" and "to-discussion"`.
