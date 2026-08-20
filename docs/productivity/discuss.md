# discuss

## What it does

Interrogates a half-formed idea until it has a shape, then publishes that shape to your repo's GitHub Discussions so it survives the session.

Two moves. First `grilling` works your idea as a **design tree**, asking the questions whose prerequisites are already answered — a round at a time, each question with a recommended answer, then waiting for you. Then `to-discussion` writes the result up: current state as the top post, this round's increment as a comment.

You decide when to stop. There is no requirement to empty the tree.

## When to reach for it

When you have thought something through — or are about to — and the thinking is the valuable part. Especially when the next person to need it is you in three weeks, or a teammate's agent that will not have been in the room.

Not for recording a meeting. Not for anything already decided; a decision that is settled wants a different home.

## Common questions

**Does it need a repo with Discussions on?**
Yes. `gh api -X PATCH repos/OWNER/REPO -F has_discussions=true`, or Settings → General → Features.

**Where does it put things?**
Whichever category you confirm on the first run — `Ideas` if it exists. Remembered in `docs/agents/discussion-config.md` afterwards.

**What if I already have a thread on this?**
Matched by the `[slug]` prefix in the title. Same slug, same thread: it appends rather than starting a second one.

**What if somebody edited the thread by hand?**
It notices and stops before overwriting the top post, then asks you what to do with their content. Hand-written sections — dissent especially — are preserved verbatim.

**Can I run it mid-conversation?**
Yes. It publishes the state as it stands; the next run appends.

## It's working if

You come back weeks later, open the thread, and the `Ruled out` section stops you re-proposing something you already rejected — because the reason is written down, not just the verdict.
