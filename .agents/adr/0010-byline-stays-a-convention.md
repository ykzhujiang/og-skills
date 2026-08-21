# The AI byline stays a convention, with no mechanical check

Every AI-written top post and session comment opens with a `📝 代写` byline, so a human contribution is identifiable by its **absence**. No automated verification was added.

## The option rejected

**Refuse to publish a post or comment whose body lacks the byline** — a few lines of code, run immediately before the write.

Rejected by the repo owner as not worth it: the convention is simple, both sides follow it, and a post written by a person carries no byline while one written by an agent does.

## Why it was proposed, and what the decision accepts

The inference "no byline, therefore human" holds only while nobody ever forgets, and **forgetting is silent**: the post publishes normally, no error, no anomaly — and a reader then attributes agent text to a person *confidently*, because the convention says they may. The skill's own text already concedes this: "This is a convention, not a guarantee. A run that forgets the byline silently passes AI text off as human."

Two things make it worse in a shared repo. Contributors scale as N humans plus N agents, so the chance of an omission rises with team size while the chance of detection stays at zero. And the fallback identity signal is unreliable: the GitHub author field shows whichever token was used, so a shared credential makes every contribution look like one person — meaning "no byline" cannot even establish *which* human.

It also sits uneasily beside the accepted principle that robustness belongs in code rather than in people's diligence, since remembering a byline is exactly diligence.

## Decision

Convention only, as the owner decided. Recorded here rather than argued in the skill text, so the reasoning is available if an omission is ever discovered in the wild.

A separate GitHub identity for the agent would make the distinction structural instead of disciplined. It is not built, and building it later does not invalidate anything written under the convention.
