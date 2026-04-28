# Attribution — promote-strategist

**Created** : 2026-04-28
**Author** : François Neumann (promote project)
**Sub-school** : A — Kitchen-sink orchestrator

## Purpose

This skill is the **entry point** of the `promote` system, Part 1. It orchestrates 18 sub-skills and 11 reference documents to produce a complete product promotion strategy from a URL.

## Composition

The strategist is an **orchestrator** ; it does not contain the marketing intelligence itself. The intelligence lives in:

- **Operator skills** (sub-school D, persona-incarnée): `promote-hormozi`, `promote-schwartz`, `promote-cialdini`, `promote-voss`, `promote-holiday`, `promote-ammar`, `promote-paul-graham`, `promote-x-mastery`, `promote-mrbeast`, `promote-steve-jobs`, `promote-customer-research`.
- **Framework skills** (sub-school C, scoped surgeon): `promote-jtbd-switch`, `promote-dunford-positioning`, `promote-growth-four-fits`, `promote-plg-design`, `promote-geo-optimization`, `promote-ai-content-pipeline`, `promote-pricing-strategy`.
- **Utility skills**: `promote-huashu-nuwa` (skill builder, used to extend the system).
- **Reference docs** (`references/*.md`): `skill-grammar.md`, `strategy-kernel.md`, `category-design.md`, `growth-loops.md`, `metrics-canon.md`, `psychology-canon.md`, `sales-canon.md`, `demand-gen.md`, `attribution-canon.md`, `network-effects.md`, `copy-frameworks.md`.

See `_ATTRIBUTIONS.md` in each sub-skill for individual provenance and licensing.

## License

The orchestration logic, references, and templates are released under the project's MIT license (see top-level `LICENSE`). Sub-skills retain their individual licenses.

## Skill grammar compliance

Audited against `../../references/skill-grammar.md` checklist on creation. See "Pattern Compliance" section in SKILL.md for explicit pattern coverage. **All 14 patterns hit** (the strategist is the most pattern-dense skill in the project).
