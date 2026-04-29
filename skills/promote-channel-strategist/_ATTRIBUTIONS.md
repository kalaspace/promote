# Attribution — promote-channel-strategist

**Created** : 2026-04-29 (v1.1.0)
**Author** : François Neumann (claude_promote orchestrator)
**Sub-école** : A — Kitchen-sink mini orchestrator

## Purpose

Orchestrates the channel mix decision in `promote-strategist` P3.B-D. Proposes channels actively (not just validates user input), invokes operator skills in strategic-consultation mode, arbitrates inter-operator conflicts, and produces the final mix with primary/secondary/deferred/excluded categorization.

## Critical innovation v1.1.0

Solves the "channel myopia" gap identified in the v1.0.0 real-test feedback (only Reddit + LinkedIn proposed because that's all the user mentioned). Forces active proposition + operator consultation.

## Composition

The skill consumes:
- All operator skills in `skills/promote-*/` (in strategic-consultation mode)
- 8 frameworks in `references/channel-*.md` (read directly)
- Strategist artifacts P3.A (foundations)

It produces:
- `strategy/06-distribution-plan.md` (primary + secondary + deferred + excluded + tradeoffs résolus)
- `strategy/operator-consultations/{operator}.md` (one file per consultation, consumed by P4 strategist + content-batcher)

## License

MIT (orchestration code, schema, prompts).

## Pattern compliance

13/14 patterns hit. Pattern 5 (genre-adjusted thresholds) is implicit via the composite score interpretation (B2B vs B2C contexts shift weighting), but not explicitly tabulated. Pattern 6 (strengths to PRESERVE) is N/A since this skill produces new artifacts, not edits.
