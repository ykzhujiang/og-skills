# Keep discussions in GitHub Discussions, not in files in the repo

An earlier draft of this system put a discussion in a markdown file under `docs/`, versioned alongside the code. That was wrong, and the reason it was wrong is worth writing down because the instinct to version everything is strong.

## Why not files

**A discussion does not want to branch with the code.** A file in the repo forks when the branch forks. Two branches then hold two divergent versions of the same argument, and merging them is a text merge over prose — the worst possible representation of "we disagreed about this".

**The people who need to be in it may not have the repo.** Design arguments include people who do not clone, review, or check out anything. A file is invisible to them.

**Discussions already have the mechanism we would otherwise invent.** A comment stream *is* a versioned sequence of thoughts, with authorship, timestamps, and notification built in. Writing our own version history in markdown reimplements this badly.

## Decision

Discussions live in GitHub Discussions. Code stays versioned locally. Collaboration state is queried live, never cached.

This splits the system by a clean line: **code is versioned, collaboration state is queried.** Anything that needs to branch with the code belongs in the repo; anything that needs to be reachable by a person without a checkout does not.

## What this forces

- **No local snapshot, ever.** A cached copy of a thread is a second source of truth that is stale the moment a human types into the web UI. The thread is read before every write.
- **No offline fallback.** Unreachable GitHub means the run stops. A local degradation path would recreate the divergence this decision exists to prevent.
- **Concurrent edits are real** and must be handled rather than assumed away — see [0002](./0002-lasteditedat-not-updatedat.md).
