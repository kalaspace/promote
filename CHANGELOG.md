# Changelog

All notable changes to promote (the `promote` plugin).

## [1.0.0] — 2026-04-28

First public release. Part 1 (`promote-strategist`) is feature-complete and packaged as a Claude Code plugin.

### Added

- **Plugin packaging** : `.claude-plugin/marketplace.json` (single-plugin marketplace) and `.claude-plugin/plugin.json` (manifest with `userConfig.promote_home`).
- **20 skills** with `promote-*` namespace prefix:
  - 1 orchestrator: `promote-strategist` (kitchen-sink, 5-phase pipeline, 15 P3 delegations).
  - 11 operator personas (sub-school D): `promote-hormozi`, `promote-schwartz`, `promote-cialdini`, `promote-voss`, `promote-holiday`, `promote-ammar`, `promote-paul-graham`, `promote-x-mastery`, `promote-mrbeast`, `promote-steve-jobs`, `promote-customer-research`.
  - 6 framework skills (sub-school C, scoped surgeon): `promote-jtbd-switch`, `promote-dunford-positioning`, `promote-growth-four-fits`, `promote-plg-design`, `promote-geo-optimization`, `promote-ai-content-pipeline`.
  - 1 cherry-picked tactical: `promote-pricing-strategy`.
  - 1 utility: `promote-huashu-nuwa` (skill builder).
- **11 reference documents** in `references/`:
  - `skill-grammar.md` (chap 34 du livre Dinguerie Claude Code, source canonique de la grammaire de skill).
  - `strategy-kernel.md` (Rumelt — anti-bullshit validator).
  - `category-design.md` (Play Bigger).
  - `growth-loops.md` (Reforge).
  - `metrics-canon.md` (North Star Framework).
  - `psychology-canon.md` (Cialdini + Ariely + Kahneman).
  - `sales-canon.md` (SPIN + JOLT Effect).
  - `demand-gen.md` (Refine Labs / Walker).
  - `attribution-canon.md` (dark social, self-reported attribution).
  - `network-effects.md` (Cold Start Problem, Chen).
  - `copy-frameworks.md` (PAS / AIDA / BAB).
- **`promote-strategist` orchestrator**:
  - 5-phase pipeline: P0 INTAKE → P1 PRODUCT DEEP DIVE → P2 MARKET RESEARCH → P3 STRATEGY SYNTHESIS (15 delegations) → P4 PACKAGING.
  - 14-artifact deliverable per campaign + `handoff-to-executor.yaml` (contract for Part 2).
  - 5 reference docs in `skills/promote-strategist/references/` (pipeline-phases, intake-questions, delegation-matrix, strategy-schema, completeness-checklist).
  - 15 templates in `skills/promote-strategist/templates/`.
  - Modes: guided (default), autopilot, resume.
- **Runtime path resolution hierarchy**: `$PROMOTE_HOME` > `./campaigns/<slug>/` (cwd-relatif) > `${CLAUDE_PLUGIN_DATA}/campaigns/<slug>/`.
- **`install.sh`** — bash script for dev mode (creates `.claude/skills/promote-* → ../../skills/promote-*` symlinks).
- **Multi-agent compatibility** via `npx skills add` (Vercel Labs CLI). The `skills/` root layout is auto-detected.
- **Documentation**: `README.md` (3 install modes), `INSTALL.md`, `docs/architecture.md`, `docs/attributions.md`.
- **Audit reports** in `skills-source/audit-reports/` (autonomy phase 0.A.5 + summary phase 0.B).

### Notes

- Part 2 (`promote-executor`) is in development. It will consume `strategy/handoff-to-executor.yaml` produced by the strategist, and add credentials/MCPs/cron orchestration for actual posting and analytics.
- Public skills imported (Dunford, JTBD, Voss, Cialdini, pricing, customer-research) come from `wondelai/skills` and `coreyhaines31/marketingskills` repos under MIT license. Cross-skill references in their `description:` fields have been re-routed to the `promote-*` namespace.
- 7 skills were imported from François Neumann's local skill library (Hormozi, Ammar, Paul Graham, X-Mastery, MrBeast, Steve-Jobs, huashu-nuwa) and renamed with the `promote-` prefix to avoid namespace collisions with global installs.

### Known limitations

- The strategist invokes `WebFetch` and `WebSearch` extensively in P0/P2; rate limits may apply.
- `promote-mrbeast` is conditional (only invoked if video channels are retained in the channel mix).
- `promote-plg-design` is conditional (only for software products).
- The completeness checklist (40 points) gates the final packaging; a campaign scoring < 70% is escalated for manual review.
