---
name: design-critic
description: Run a critic loop on a UI — a fresh, screenshot-only critic subagent scores the page out of 10 against a fixed rubric and names the biggest gaps; the implementer fixes and re-shoots until the critic gives 9+/10 or a stop rule fires. Use when asked to "get this page to a 9/10", "critique this design", "polish this UI", "run the design critic", "score this page", or to iterate a page's visual quality before review.
---

# Design critic loop

From Anshu Chimala, "How to turn your AI into a world-class designer" (Lenny's Newsletter, Sep 2026),
technique 3. The coding agent is too close to its own work: it has read the code, so it sees what it
meant, not what rendered. A separate critic that sees **only pixels** catches what users will see.

## Roles

- **Implementer (you):** owns the code, the screenshots, and every decision about which finding to act on.
- **Critic (subagent):** a fresh `Agent` per round, strongest model available (`model: "opus"` or better),
  given **screenshots only** — no code, no diff, no PR text, no prior rounds' scores. A critic that sees
  last round's 7 anchors to it; a fresh one judges the pixels.

Use the strong model for judgment and keep implementation on the main thread — that's where the cost is.

## Setup (once)

1. **Capture script.** Write a script in the scratchpad that shoots every state that matters: each
   meaningful variant (empty/populated, open/refused/error), light + dark, desktop (~1280–1440) + phone
   (~400). Prefer the real page in its real chrome (layout, sidebar, real fonts) over an isolated
   component preview — previews often lack the app's web fonts and context. Use the project's browser
   tool, following the project's browser-tool policy.
2. **Product brief** for the critic — 3–5 sentences: who lands here, what decision they make, what
   success looks like. Purpose, not implementation. No mention of what changed or why.
3. **Moodboard.** 1–3 screenshots of the surrounding product (or references the user names) so the
   critic judges fit. Label them **"context, not a target"** — the critic should not ask you to copy them.
4. **Constraints list** (implementer-only, never given to the critic): design-system components,
   i18n, dark-mode pairing, accessibility, copy that's awaiting sign-off, anything the user ruled out.

## The critic prompt

Send this (fill the brackets), with the image paths:

```
You are a principal product designer reviewing a UI from screenshots alone. You have not seen the
code and won't. Read each image with the Read tool.

Product brief: [brief]
Screens: [path — what state it shows], ...
Moodboard (context for fit, NOT a target to copy): [paths]

Score each dimension 1–10, using the anchors, then give an overall score (not an average — weight what
matters most for this screen's job):
1. Job clarity — in 5 seconds, does a first-time user know what this screen is for and what to do?
2. Decision support — if the screen asks for a choice, can the user tell the options apart and know
   which fits them? Is the recommended path obvious without being pushy?
3. Hierarchy — one clear focal point; heading, body, meta and actions read in the right order.
4. Spacing & alignment — consistent rhythm, aligned edges, no orphaned or cramped elements.
5. Typography — size/weight contrast does the work; no walls of same-weight text.
6. Color & contrast — purposeful color, readable contrast (incl. dark mode), states look like states.
7. State design — disabled/blocked/empty/error states explain themselves and offer a way forward.
8. Restraint — every element earns its place; nothing decorative, redundant, or "AI-generic".
9. Character — does it feel considered and on-brand, or like a default template?
10. Responsiveness — the phone layout is designed, not just squeezed.

Anchors: 10 = best-in-class (Linear/Stripe level); 9 = a top product team would ship it unchanged;
7 = competent but generic; 5 = works, clearly unpolished; 3 = confusing.

Then list the TOP 3–5 gaps between this and a 9+, most important first. Each gap: what you see (which
screenshot, where), why it costs the user, and a concrete change. No praise, no nits below the top 5.
End with a line exactly: SCORE: <overall>/10
```

## The loop

Score with a **panel of three** fresh critics run in parallel and take the **median**. One critic is
noisy (±0.5–1.0 between identical screens) and has its own taste: in practice single critics reverse
each other round to round ("add previews" → "previews don't earn their space"), and chasing each one
turns the loop into a random walk. Act on a gap only when **two or more** panelists raise it; treat a
one-off ask as taste unless it's a correctness or accessibility issue.

1. Capture → spawn the panel → take the median `SCORE:` and the gaps the panel agrees on.
2. Triage each gap against the constraints list: **act**, **adapt** (same intent, compliant means), or
   **decline** (say why). Don't chase a gap that would break a project rule or the user's stated scope.
3. Implement, keep tests green, re-capture, **new critic** (fresh agent, same prompt, no history).
4. Keep a round log in the scratchpad: score, gaps, what you did with each.

## Tournament variant

When single-track iteration stalls, run rounds as a tournament: 3 builder subagents each start from
the last winner, take the panel's agreed gaps plus a _different_ emphasis each, and write a variant
file that a flock-serialized capture script installs, shoots and restores. The judge panel scores the
3 variants **plus last round's winner as a control** (median picks the winner). The control is what
exposes taste reversals — when judges start praising what the previous panel asked you to remove,
the open question is a decision for the user, not a gap.

## Stop rules

- **Done:** panel median ≥ 9.
- **Reversals:** if a panel asks you to undo something an earlier panel asked for, stop and ask the
  user which direction they want — that's taste, not a gap.
- **Plateau:** two rounds without a ≥0.5 gain → stop and surface the remaining gaps to the user; the
  ceiling is probably a decision (copy, scope, product) the user owns.
- **Cap:** 6 rounds. Past that you're optimizing for the critic, not the user.
- **Declined gaps** that keep recurring and block a 9: report them, with why they were declined.
  Never game the score (e.g. hiding a hard state from the screenshots).

## Report

Score trajectory (r0 → rN), what changed per round, declined gaps and why, and before/after images.

Related: `design-discover` (directions before building), `design-cut` (subtraction pass — run it
before the critic; it's the cheapest score gain).
