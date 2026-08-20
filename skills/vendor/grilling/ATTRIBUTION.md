# Vendored: `grilling`

This skill is **not ours**. It is copied verbatim from
[mattpocock/skills](https://github.com/mattpocock/skills) — `skills/productivity/grilling/`.

- **Author:** Matt Pocock (<https://www.aihero.dev>)
- **Licence:** MIT — full text at [`licenses/mattpocock-skills-LICENSE`](../../../licenses/mattpocock-skills-LICENSE)
- **Vendored at:** upstream commit `9c9f36ccd3995266cd675468af71639c8dde1ec5`
- **Modifications:** none. Do not edit this folder.

## Why it is vendored rather than declared as a dependency

`discuss` calls `grilling`. If `grilling` were left to a separate install step, a
tester who missed it would get a partial, silent failure — `discuss` would publish
whatever was already in the conversation without ever interrogating it, which looks
like working software. Bundling it makes the install one step and keeps a test
report about *our* skill rather than about a missing dependency.

The cost is drift: upstream changes do not reach here automatically. Re-sync by
copying the folder again and updating the commit above.
