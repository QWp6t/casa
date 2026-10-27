---
name: design-discover
description: Push an AI past its bland defaults before building a UI — derive a creative direction from a real random seed, explore many cheap concepts from a specific outside inspiration, then write an ambitious build brief. Use when starting a new page, landing page, onboarding flow, or visual refresh; when the user says "explore directions", "give me options", "make it less generic", "be bold", "moodboard", or "design brief".
---

# Discover and define

From Anshu Chimala, "How to turn your AI into a world-class designer" (Lenny's Newsletter, Sep 2026),
Discover/Define stages, techniques 1–2. LLMs pick the most predictable token at every step, so their
first design is the committee average. These steps force divergence _before_ any code exists.

## 1. Seed strings (real randomness)

Models can't be random on request — "pick a random palette" returns the same three palettes. Get
entropy from the shell and derive the direction from it deterministically:

```bash
seed=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n'); echo "$seed"
```

Map slices of the seed to axes, e.g. byte 0 → hue family, byte 1 → layout archetype (editorial,
split, grid, single-column, asymmetric), byte 2 → type pairing, byte 3 → density, byte 4 → motion
level. Write the mapping table down first, then read the seed through it. Generate 3–5 seeds for
3–5 genuinely different directions. Inside a design system (e.g. a product dashboard), seed only
the axes the system leaves open — layout, emphasis, imagery, copy angle — not color or type.

## 2. Ambitious prompts from outside inspiration

Name a specific, non-software reference: a video game's menu, an interior-design trend, a museum
installation, a print magazine. "Make it modern" produces nothing; "a train-station departures board"
produces a direction.

1. Ask for **10–15 broad concepts, one or two lines each, no detail**. Cheap and wide.
2. The user (or you, with stated reasons) keeps 2–3. Refine those only.
3. Have the AI **write the build prompt** for the chosen direction — layout, type, color, imagery,
   motion, copy voice, and what it must _not_ do.

## 3. Hand off

The brief is the input to the build. After the first build: `design-cut` (subtract), then
`design-critic` (score to 9+).

Ground rules from the article:

- **Steer yourself.** Pasting AI ideas back into AI converges on generic. Add a human judgment at
  each step.
- **Keep failed prompts.** Save briefs that didn't land (scratchpad or a notes file) and retry them
  on newer models.
- **Images over shapes.** Agents fall back on gradients and blobs. If the project has an image/video
  generation tool or key (gitignored, tight spend cap), use real generated imagery instead.
