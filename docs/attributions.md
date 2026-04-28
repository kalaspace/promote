# Attributions — `promote` system

This document consolidates the provenance and licensing of all 20 skills + 11 reference documents in the `promote` Part 1 system.

For per-skill detail, see `_ATTRIBUTIONS.md` in each skill directory under `.claude/skills/`.

## Imported from François's local skill library

These were created by François Neumann via `huashu-nuwa` (skill builder) prior to this project. Imported into `promote` and renamed with `promote-` prefix.

| Skill (renamed) | Original name | Original location | Sub-school |
|---|---|---|---|
| `promote-hormozi` | `alex-hormozi-perspective` | `~/.claude/skills/` | D — Persona-incarnée |
| `promote-ammar` | `oussama-ammar-perspective` | `~/.agents/skills/` | D — Persona-incarnée |
| `promote-paul-graham` | `paul-graham-perspective` | `~/.agents/skills/` | D — Persona-incarnée |
| `promote-x-mastery` | `x-mastery-mentor` | `~/.agents/skills/` | D — Persona-incarnée (multi-operators) |
| `promote-mrbeast` | `mrbeast-perspective` | `~/.agents/skills/` | D — Persona-incarnée |
| `promote-steve-jobs` | `steve-jobs-perspective` | `~/.claude/skills/` | D — Persona-incarnée |
| `promote-huashu-nuwa` | `huashu-nuwa` | `~/.agents/skills/` | Utility / skill builder |

## Imported from public repos (cherry-picked)

| Skill (renamed) | Original name | Source repo | License |
|---|---|---|---|
| `promote-dunford-positioning` | `obviously-awesome` | github.com/wondelai/skills | MIT |
| `promote-jtbd-switch` | `jobs-to-be-done` | github.com/wondelai/skills | MIT |
| `promote-voss` | `negotiation` | github.com/wondelai/skills | MIT |
| `promote-cialdini` | `influence-psychology` | github.com/wondelai/skills | MIT |
| `promote-pricing-strategy` | `pricing-strategy` | github.com/coreyhaines31/marketingskills | MIT |
| `promote-customer-research` | `customer-research` | github.com/coreyhaines31/marketingskills | MIT |

For each, the original `name:` frontmatter has been changed to the renamed value, the `description:` field has been patched to redirect cross-skill references to their `promote-*` equivalents (when those exist in this project) or to remove them (when the referenced skill is not part of `promote`). All other content is preserved as in the source.

## Created in this project (via huashu-nuwa methodology, hand-written)

These skills were built specifically for `promote` to fill gaps not covered by imports. They follow the grammar in `references/skill-grammar.md`.

### Operator skills (sub-school D — Persona-incarnée)

| Skill | Source distillation | Author |
|---|---|---|
| `promote-schwartz` | Eugene Schwartz, *Breakthrough Advertising* (1966), Halbert notes, modern decompositions (Stefan Georgi, Justin Goff, Kim Krause Schwalm) | François Neumann |
| `promote-holiday` | Ryan Holiday, *Trust Me I'm Lying* (2012), *Perennial Seller* (2017), *Ego Is The Enemy* (2016), Daily Stoic newsletter, public interviews | François Neumann |

### Framework skills (sub-school C — Scoped surgeon)

| Skill | Source | Author |
|---|---|---|
| `promote-growth-four-fits` | Brian Balfour Reforge essays (2017+), Reforge curriculum 2017-2025 | François Neumann |
| `promote-plg-design` | Wes Bush *Product-Led Growth* (2019), Reforge PLG curriculum, OpenView PLG Index, post-2022 industry analyses (a16z, Bessemer State of Cloud) | François Neumann |
| `promote-geo-optimization` | Aggarwal et al. arXiv:2311.09735 (Nov 2023), Profound state of GEO 2024-2025, Semrush AI Search Report 2024, Ahrefs studies 2025 | François Neumann |
| `promote-ai-content-pipeline` | Mollick *Co-Intelligence* (2024), Reforge AI content curriculum 2025, observed practice from Lenny Rachitsky / Stratechery / Substack pros 2024-2025 | François Neumann |

### Orchestrator (sub-school A — Kitchen-sink)

| Skill | Author |
|---|---|
| `promote-strategist` | François Neumann |

## Reference documents

All in `references/`. Original synthesis work by François Neumann based on the canonical sources cited in each document.

| Reference | Primary sources |
|---|---|
| `skill-grammar.md` | Chapter 34 of *Dinguerie Claude Code: les skills* (François Neumann), based on lecture verbatim of 18 SKILL.md files |
| `strategy-kernel.md` | Richard Rumelt, *Good Strategy Bad Strategy* (2011), *The Crux* (2022) |
| `category-design.md` | Lochhead, Ramadan, Peterson, Maney, *Play Bigger* (2016) |
| `growth-loops.md` | Brian Balfour Reforge essays, Kevin Kwok *The Arc of Collaboration* |
| `metrics-canon.md` | Amplitude *The North Star Playbook* (2019+), Sean Ellis (Dropbox origin) |
| `psychology-canon.md` | Cialdini *Influence: New and Expanded* (2021) + *Pre-Suasion* (2016), Ariely *Predictably Irrational* (2008), Kahneman *Thinking Fast and Slow* (2011), Thaler *Nudge* (2008) |
| `sales-canon.md` | Rackham *SPIN Selling* (1988), Dixon & Adamson *Challenger Sale* (2011) + *JOLT Effect* (2022), Voss *Never Split the Difference* (2016) |
| `demand-gen.md` | Chris Walker / Refine Labs / Passetto corpus 2020-2025, *State of Demand Gen* podcast |
| `attribution-canon.md` | SparkToro (Rand Fishkin), HockeyStack / Dreamdata / Common Room reports 2023-2025, Refine Labs corpus, Reforge curriculum |
| `network-effects.md` | Andrew Chen, *The Cold Start Problem* (2021) |
| `copy-frameworks.md` | Copywriting tradition (Ogilvy, Schwartz, Halbert, Sugarman, Caples) |

## License

The orchestration logic, references, templates, and original distillations are released under the MIT License (see top-level `LICENSE`).

Imported skills retain the licenses of their original sources. wondelai/skills and coreyhaines31/marketingskills are under MIT.

The frameworks distilled (positioning canvases, JTBD methodology, awareness ladders, etc.) are public-knowledge methodologies and are not exclusive intellectual property of any one author or company. The original books and corpus from which they are distilled remain under the copyright of their authors and publishers ; this project does not reproduce text from them, only teaches the frameworks in original wording.

For redistribution :
- The skill logic, frameworks, and orchestration are MIT.
- The branding "promote" and identity are unrestricted.
- Personas (Hormozi, Schwartz, Cialdini, etc.) are public-figure personas distilled from public material — the role-play implementations are original.
- Verify the LICENSE in each public-source skill (wondelai, coreyhaines) before public distribution.
