# No digging for a single root problem

Nested problems are real. A unique bottom to the nest is not. `discuss` does not ask the user to "get to the real problem underneath", and where a discussion does settle on a root, it is recorded as a chosen hypothesis rather than a discovered fact.

## The option rejected

**Require the discussion to identify the root problem** — the "five whys" move, applied to ideas instead of defects. Rejected because the selection of *which* cause is the root is fixed by the question being asked and by whose position it is asked from, not by the causal structure alone. The rule would demand an act of discovery for something that is an act of choice, and the reliable result of demanding the impossible is that the first sufficiently deep-sounding candidate gets promoted and the whole tree is then built to serve it.

## Why the selection is a choice

**Philosophy of causation says the structure is symmetrical.** Mackie: among factors that were jointly sufficient and severally necessary, "there are no firm rules governing this selection", and "the statement that the presence of this material caused the fire would be as true as the statement that the spark caused it, and merely in some ways less interesting" (*The Cement of the Universe*, 1974, pp. 34–36). What breaks the symmetry is the **causal field** — the background held fixed by the question — and the enquirer's current purpose.

**Position determines the answer.** Hart & Honoré: the cause of an Indian famine is the drought to the local peasant and the government's failure to build reserves to the World Food Authority, with the drought demoted to a mere condition (*Causation in the Law*, 1959). Dekker states the operational form: "Cause is not something you find. Cause is something you construct. How you construct it… depends on where you look, what you look for, who you talk to… and likely on **who you work for**" (*The Field Guide to Understanding 'Human Error'*, 3rd ed., 2014, p. 76).

**Safety science rejects the singular framing, including its own institutions.** Card: "accidents are seldom the result of a single root cause"; a full causal tree for one incident "uncovers more than 75 whys", of which five whys reaches "<3% of the opportunities for improvement"; "its popularity is not the result of any evidence that it is effective" (*BMJ Quality & Safety* 26(8), 2017, 671–677). Leveson names the pull: "root cause seduction… provides an illusion of control" (*Engineering a Safer World*, 2011, p. 403, crediting Carroll 1995). The NPSF's own RCA guidance concedes the point and renames the method: the term "implies that there is one root cause, which is counter to the fact that health care is complex", and there is "seldom one magic bullet" (*RCA²*, 2015, p. 2).

**Popper reaches the same place from epistemology.** Science "does not rest upon solid bedrock… if we stop driving the piles deeper, it is not because we have reached firm ground. We simply stop when we are satisfied that the piles are firm enough" (*The Logic of Scientific Discovery*, §30). He ranks problems by depth but says the notion "defies any attempt at exhaustive logical analysis" (*Objective Knowledge*, p. 197). Two unrelated literatures, one conclusion: **you stop digging when it is deep enough, not when you hit bottom.**

## The steelman, and what survives it

Root-cause practice has a real defence and it was sought deliberately, because the evidence above is one-sided. The defence reframes the output: "RCA represents a hypothesis-generating approach… we must regard any proposed corrective action as speculative — a hypothesis that requires testing" (Trbovich & Shojania, *BMJ Quality & Safety* 26(5), 2017, 350–353). Toyota's own logic is the same: a specification *is* a hypothesis, tested by whether the countermeasure works (Spear & Bowen, *HBR*, Sept–Oct 1999). Philosophically this converges with Hitchcock & Knobe, who argue the selectivity is the point: "our concept of causation enables us to pick out those factors that are particularly suitable as targets of intervention" ("Cause and Norm", *Journal of Philosophy* 106(11), 2009).

Honest counter-evidence recorded: Ohno himself did claim singularity — "we can get to the real cause of the problem" (*Toyota Production System*, 1988). And field data does not support one root: 214 real RCA reports produced 504 root causes, averaging 2.4 each, with 82% of recommendations rated weak (*BMC Health Services Research* 20:507, 2020); an audit of 91 five-whys cases found 48.4% with no valid causal chain and only 39.6% eliminating the cause (*IJLSS*, 2025). No controlled trial of the framework exists (Percarpio et al., 2008).

So the steelman does not rescue "find the root". It rescues **"pick a root, call it a hypothesis, and test it"** — which is the decision below.

## Decision

Never require a root. If a discussion selects one, the `Settled` entry names it, marks it a hypothesis, and states what would show it wrong; dropped candidates go to `Ruled out` with reasons. It does **not** go in `Verified facts` — nobody measured it, somebody picked it.

## What this forces

- Anywhere a root is asserted, the alternatives that were dropped must be recoverable, or the choice is unauditable.
- In a shared repo this stops being cosmetic. Two members will construct different roots from the same events, and both will be right relative to their position — so a thread must show *whose* root it is holding.
