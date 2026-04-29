# Attribution — promote-content-batcher

**Created** : 2026-04-29 (v1.1.0)
**Author** : François Neumann (claude_promote orchestrator)
**Sub-école** : C — Scoped surgeon

## Purpose

Solves the v1.0.0 gap "what do I do after the strategist produces 14 concrete days + 76 outlines?". This skill converts outlines → concrete posts on demand (J+14, J+28, J+42, etc.) using the same logic as the strategist's P4 Content Production phase, factored in `references/content-production.md`.

## Critical innovation v1.1.0

The strategist produces a strategic skeleton + 14 days concrete content + 76 days outlines. Without content-batcher, the user is stuck after 14 days. With content-batcher, the user can extend their concrete calendar in batches of any size.

## Companion to

- `promote-strategist` (produces the calendar with outlines after J+14)
- `references/content-production.md` (factored production logic)
- All 17+ operator skills (invoked in production mode for content generation)
- `templates/post.md.template` (output format per post)

## License

MIT (orchestration code, schema, prompts).

## Pattern compliance

13/14 patterns hit. Pattern 5 (genre-adjusted thresholds) is implicit via per-channel quality gates, not explicitly tabulated.
