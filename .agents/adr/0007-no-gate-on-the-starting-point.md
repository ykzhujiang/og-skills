# The starting point of a discussion is not gated

A discussion may open with an observation, a capability, an itch, or a question. `discuss` does **not** require a stated problem before it will engage.

## The option rejected

**Require the user to state the problem before grilling begins**, refusing to proceed without one. It is the intuitive design, it was proposed, and it is wrong for three separate reasons.

**It is self-refuting.** The proposal to add this gate arrived, in the session that produced this ADR, as a general design intuition with no problem attached. The rule would have blocked the thinking that produced it. A rule that vetoes its own origin is not merely inconvenient — it is evidence the rule misdescribes how ideas form.

**It manufactures the thing it is meant to prevent.** Asked for a problem they do not have, people supply a plausible one. The invented problem then roots the design tree, every branch serves it, and the result reads as unusually rigorous. **An unfocused discussion is visibly unfocused; a discussion built on a retrofitted problem proceeds with confidence in the wrong direction**, and that is the harder failure to catch.

**The strongest advocate of problem-priority withdrew it.** Popper argued that "science starts from problems, and not from observations" (*Conjectures and Refutations*, ch. 10 §VI, p. 222 in the 1968 Harper printing), then qualified it himself: "every scientific problem arises, in its turn, in a theoretical context. It is soaked in theory. So I used to say that **we may begin the schema at any place**" (*Unended Quest*, §29, p. 153). Independently: Rittel & Webber on wicked problems — "the information needed to understand the problem depends upon one's idea for solving it" (*Policy Sciences* 4(2), 1973, p. 161); Dorst & Cross — "creative design is **not** a matter of first fixing the problem and then searching for a satisfactory solution concept" (*Design Studies* 22(5), 2001, p. 434); Simon — "there are no WSPs, only ISPs that have been formalized for problem solvers" (*Artificial Intelligence* 4(3–4), 1973, p. 186). Kuhn inverts the order outright: a paradigm supplies "a criterion for choosing problems", so the problem set is downstream of the paradigm (*SSR* 2nd ed., p. 37; ch. V is titled "The Priority of Paradigms").

## What argues for the gate, and why it does not win

The empirical evidence runs the *other* way and was not ignored. Kruger & Cross found problem-driven designers "produce the best results in terms of the balance of both overall solution quality and creativity", while solution-driven ones scored lower on quality (*Design Studies* 27(5), 2006). Problem-finding correlates with creative outcomes (Abdulla et al., *Psychology of Aesthetics, Creativity, and the Arts* 14(1), 2020).

This supports **problem-first as a heuristic worth encouraging**, not as an admission gate. The two claims were being conflated: it can be simultaneously true that inquiry has no obligation to begin with a problem, and that discussions which find one early go better. A gate enforces the first; only encouragement serves the second.

Also weighed: no study was found, in either direction, that manipulates a mandatory problem statement and measures outcomes. The decision is a judgement, not a finding.

Amazon is often cited for the opposite conclusion and, read closely, is not evidence for a gate. Its PR/FAQ is a mock press release for a *finished product* — "start by defining the customer experience" — and the problems are an **output** of drafting it, over ten-plus revisions. What Amazon supports is a short written artefact with a hard length limit before resources are committed, which is a different rule.

## Decision

Starting point free; landing point checked. The obligation moves to publish time, as the closure check in `to-discussion` Step 5a: `讨论什么` and `当前想法` must be a recognisable pair, and where they are not, the thread says so in as many words — including `尚未找到这场讨论要解决的问题`, which is an honest state.

## What this forces

- **`grilling` cannot be relied on to enforce this**, since it is vendored and unedited. The override lives in `discuss`, which is why that skill has prose at all instead of two Skill calls.
- **"No question yet" must stay publishable.** The moment that state is treated as a failure, the retrofitting pressure returns, entering through the back door.
- The check is against the whole thread, not the round, so an early round that paired the thread already satisfies it.
