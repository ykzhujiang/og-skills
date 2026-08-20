# Working in this repo

Skills live in bucket folders under `skills/`:

- `productivity/` — ours, shipped
- `vendor/` — third-party, **never edited**. Each carries an `ATTRIBUTION.md` naming author, licence, upstream path, and vendored commit. Editing one makes the recorded commit a lie; re-sync by recopying and bumping the commit.

Every skill in `productivity/` must appear in the top-level `README.md` and in `.claude-plugin/plugin.json`'s `skills` array, with the skill name linked to its `SKILL.md`. `README.md` groups entries into **User-invoked** and **Model-invoked**.

Every `SKILL.md` is either user-invoked or model-invoked, declared in **both** frontmatter and `agents/openai.yaml` — see [.agents/invocation.md](./.agents/invocation.md). The two must agree; a skill is user-invoked in both harnesses or neither. Note that opencode honours neither field, which that document covers.

Every skill carries `agents/openai.yaml` beside its `SKILL.md` with `interface.display_name` and `interface.short_description`.

Dependencies are expressed as an explicit `Call the Skill tool with "<name>"`, never as a cross-folder file reference.

Use the vocabulary in [CONTEXT.md](./CONTEXT.md), including its `_Avoid_` lists. Terms there are chosen to keep commitment levels distinct; drifting to a synonym blurs the distinction the term exists to hold.

## Verification

Claims about GitHub API behaviour must be **measured, not assumed**, and the measurement recorded. Both bugs in [TESTING.md](./TESTING.md) were assumptions that read as obviously correct. When a check's subject can be mutated by our own preceding write, treat the check as suspect until it has been observed failing *and* passing.

Update [TESTING.md](./TESTING.md) whenever the verified/unverified split changes. It is the contract with the people testing this — overstating coverage there is worse than shipping a bug.

## Decisions

Write an ADR in `.agents/adr/` when a choice is hard to reverse, would surprise someone without the context, or is a genuine trade-off. One paragraph is a legitimate ADR. Record the option **rejected** and why — that is the part that survives.
