---
name: discuss
description: Grill a fuzzy idea into shape, then publish it to GitHub Discussions.
disable-model-invocation: true
---

Call the Skill tool twice, for "grilling" and "to-discussion".

`grilling` is [vendored](../../vendor/grilling/ATTRIBUTION.md) and must not be edited, so everything below overrides it from here. Where the two conflict, this file wins.

## The starting point is not gated

**Do not require a problem before you will discuss an idea.** An idea may arrive as an observation, a capability, a half-formed dissatisfaction, or a question — and the problem it turns out to address is frequently discovered several rounds in, or reformulated after it appears.

A gate looks rigorous and fails in a way that is hard to see: asked for a problem they do not yet have, people **retrofit one**. The invented problem then becomes the root of the design tree, every branch serves it, and the whole structure reads as unusually well-reasoned. A discussion with no problem wanders visibly; a discussion with a manufactured problem proceeds confidently in the wrong direction.

What replaces the gate is a check at the other end — see **Closure** in `to-discussion`. Starting point free, landing point checked.

## Do not dig for a single root problem

Nested problems are real; **a unique bottom to the nest is not**. Where a discussion attributes a cause, the selection of *which* cause is the root is fixed by the question being asked and by whose position you are asking from, not by the causal structure alone.

So never ask the user to "get to the real problem underneath". If a discussion does settle on a root, record three things and not one: **which problem was chosen as root, that this is a hypothesis, and what would show it wrong.** A named hypothesis can be argued with; a discovered root cannot.

Reasoning and evidence: [ADR 0008](../../../.agents/adr/0008-no-single-root-problem.md).

## Reply in two tiers

Every message you send the user has two parts, in this order, and the first is not optional:

**Compressed** — the whole frontier as a table, one line per question, each with your recommended answer. A user must be able to act on this part alone without reading further.

**Expanded** — the reasoning, one block per question, in the same order.

`grilling` asks you to number each question and give a recommended answer; it says nothing about length, and unbounded rounds are the observed failure — the user stops reading and the round is wasted. Both tiers are always present: this is the same split the top post makes between its **Headline** and its **Folds**, applied to the conversation.

## Explain it so it can be argued with

In **Expanded**, lead with the plain-language version and put the terminology after it. Give at least one concrete analogy per question. Cite sources by name inline, and keep page numbers and full references at the end of the block or in the thread, not in the middle of a sentence the user is trying to follow.

The test is not whether the explanation is correct. It is whether the user can **disagree** with it. A question phrased so that only you can evaluate it does not collect a decision; it collects assent, and assent recorded as agreement is how a top post fills up with conclusions nobody actually reached.

## Report where it landed

After `to-discussion` runs, **send the user the links** — the thread, this session's comment, and the transcript at its commit. Every time, on creation and on append alike.

Its own report is printed at the end of a run; that is not the same as handing the user something to click. A publish the user cannot reach is indistinguishable from one that did not happen.
