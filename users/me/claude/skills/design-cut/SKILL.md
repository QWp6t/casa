---
name: design-cut
description: Subtraction and de-AI pass on a UI before it ships — inventory every element, cut what doesn't earn its place, and strip the visual and copy "tells" of AI-made design. Use when asked to "simplify this page", "declutter", "cut", "make it less busy", "remove AI slop", "make this not look AI-generated", or as the Deliver step before a design-critic round.
---

# Cut and de-AI

From Anshu Chimala, "How to turn your AI into a world-class designer" (Lenny's Newsletter, Sep 2026),
Deliver stage, techniques 6–7. AI adds and rarely removes: every request grows the page. Good design
is mostly what's left out.

## 1. Cut elements

Screenshot the page, then list **every** element (heading, subhead, strip, badge, icon, row, divider,
helper text, button) and give each one a verdict:

| Question                                                  | If "no"                                                                                       |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Does the user need this to make _this screen's_ decision? | Cut it, or move it to where that decision is made.                                            |
| Does it say something nothing else on screen says?        | Cut the duplicate (a subhead that restates the heading; a row that restates the description). |
| Would a user miss it if it vanished?                      | Cut it.                                                                                       |
| Is it the native/design-system component for the job?     | Swap the bespoke one for the system's.                                                        |

Then: can two elements merge? Can a paragraph become a label? Can the layout lead with the one
image/visual that carries the meaning (the article's calorie-tracker example went from a cluttered
form to an image-led grid)?

Present the cut list to the user before deleting **copy someone else owns** (PM/design sign-off).
Structural cuts you can just make.

## 2. Remove AI tells

The article's technique 7 is paywalled; this list is the house version, not a quote. Hunt for:

**Visual**

- Everything in a bordered card inside another bordered card ("card soup").
- Uniform weight: every block the same size, border, and padding, so nothing leads.
- Decorative gradients, glows, blobs, or an icon on every line item.
- Pills/badges as decoration rather than state.
- Symmetry for its own sake — two equal columns when one option is the recommended path.
- Grey-on-grey low contrast "to look subtle".

**Copy**

- Generic triplets ("Fast, responsive, and built for growth").
- Restating the heading in the subhead; "Choose X" headings above a choice that's already obvious.
- Hedged, feature-list wording instead of the user's outcome ("Chat with AI" vs. what they get).
- Em-dash chains, "seamless", "effortless", "unlock", "elevate", "powerful".

## 3. Verify

Re-shoot. The page should be shorter, with one obvious focal point. Hand it to `design-critic` —
cutting is usually the biggest single score gain. Keep tests, i18n, and accessibility intact while
cutting; deleting a locale key means deleting its usages and specs too.
