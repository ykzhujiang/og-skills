# Discussions default to a home repo, not the working repo

`to-discussion` originally published into whichever repo the agent was working in. That is the obvious default and it is wrong.

## Why the working repo is the wrong default

**Thinking crosses repos, and usually predates them.** "Which database should this use" is not a fact about the service repo the conversation happened to start in. Filed there, it is invisible from the other three services it governs, and invisible entirely before any repo exists.

**It makes the filing location an accident of context.** The same idea lands in different places depending on which checkout was open, so a month later nobody knows where to look. Worse, a slug lookup finds nothing and the skill cheerfully opens a *second* thread on a subject already discussed — the exact duplication slugs exist to prevent.

**Per-repo config means setup friction on every repo**, which in practice means the skill goes unused in the repos where setup did not happen.

## Decision

Resolve the target repo in this order, first hit wins:

1. a repo the user named in this conversation
2. `repo:` in `docs/agents/discussion-config.md`
3. the built-in **home repo** default

The home repo beats the working repo. Discussions collect in one place; code stays where it belongs.

## The disclosure requirement

**Every run states which repo it used, in one line.** A default that silently writes somewhere unexpected is worse than a prompt — the user cannot correct what they cannot see. One line (`→ owner/repo #12`) discharges this. It must not become a question: asking every run rebuilds the friction the default exists to remove.

## Cost accepted

The shipped default is the author's private repo, so anyone else installing this skill hits a permissions error until they set `repo:` themselves. Documented in `SKILL.md` and the README rather than solved, because the alternative — no default — is the friction this decision exists to remove. A fork changes one line.
