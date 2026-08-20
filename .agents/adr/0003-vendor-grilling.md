# Vendor `grilling` rather than declare it as a dependency

`discuss` is a thin shell: it calls `grilling`, then `to-discussion`. `grilling` is Matt Pocock's, MIT-licensed, from [mattpocock/skills](https://github.com/mattpocock/skills).

## Options considered

**Declare it and let the user install it separately.** Rejected. The failure mode is silent and looks like success: without `grilling`, `discuss` skips straight to publishing whatever happens to be in the conversation. The user gets a thread. It is just a thread nobody interrogated. For a repo whose purpose is *being tested by other agents*, a dependency that fails this quietly would produce test reports about a missing install rather than about our skill.

**Reimplement it.** Rejected. The round-based frontier interview is the good part, and rewriting it to avoid a dependency would be worse and dishonest about where the idea came from.

**Vendor it, attributed.** Chosen. One install step, self-contained, licence-compliant.

## Decision

`grilling` is copied verbatim into `skills/vendor/grilling/`, unmodified, with:

- `ATTRIBUTION.md` naming the author, licence, upstream path, and the exact commit vendored
- Matt's full MIT text at `licenses/mattpocock-skills-LICENSE`
- a `vendor/` bucket, so provenance is visible in the path rather than buried in a file

## The cost

Upstream fixes do not arrive automatically. This is a real cost we are choosing, not one we are hiding: re-sync means copying the folder again and bumping the commit in `ATTRIBUTION.md`. `vendor/` is never edited — a local change would make the recorded commit a lie.
