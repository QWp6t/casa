---
name: whiteboard
description: Generate a summary of what the user is asking. Trigger when a user asks for a whiteboard defense or a summary of something.
---

# Whiteboard

A benchmark for AI usage.

## Purpose

A leader should be able to pull a contributor aside at any moment ask the contributor to explain any customer-facing system the contributor has shipped.

The contributor should be able to clearly explain how it works and defend the decisions they made.

The expectation is not line-level familiarity with the code, exact function names, or implementation details.

The expectation is that if a lead were to ask "why did you do X instead of Y?" or "What happens if this actor behaves maliciously?" or "What data structure did you use here and why?" or "Where does this fail?" etc., the contributor should be able to answer with high confidence.

## Outcome

Answers that will satisfy the hypothetical leader. An overview of the project, PR, documentation, or whatever the user specifies. If nothing is specified, assume it's for the current PR. The primary goal here is to inform the user of the decisions that were made and why.
