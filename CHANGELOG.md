# Changelog

All notable changes to promote (the `promote` plugin).

## [1.2.0] — 2026-04-30 — **BREAKING — Hide internal skills**

### Why this release

Real-test feedback after v1.1.0 shipped : 39 skills `promote-*` polluted Claude's system prompt. The user reported wanting only 1 entry point (`promote-strategist`) exposed and the 38 others invisible / used only as internals by the orchestrator.

### Research finding (verified April 2026)

**No official mechanism exists in Claude Code 2026 to hide skills inside a plugin.** Verified via :
- Doc : `code.claude.com/docs/en/skills`, `code.claude.com/docs/en/plugins-reference`
- GitHub issues : anthropics/claude-code#22345 (`disable-model-invocation` ignored for plugin skills), #43875 (#19141 (`user-invocable: false` does the inverse — hides from `/` menu but skill remains exposed in system prompt).
- Practice : `anthropics/skills`, `obra/superpowers`, `wshobson/agents` all expose every skill (the latter resolves by 72 micro-plugins).

### Workaround applied : files outside `skills/`

The 37 sub-skills are now **internal prompts** under `prompts/{operators,orchestrators,personas,frameworks,tactical,utility}/{name}/prompt.md`. This directory is NOT scanned by Claude Code as a skills directory, so the prompts are invisible in the system prompt. The 2 exposed entry points (`promote-strategist` + `promote-content-batcher`) invoke them via **Read + Task tool** instead of the v1.1.0 cascade `/skill:name`.

The two-pass orchestration semantics (consultation in P3.C/F, production in P4) are unchanged. Operator consultations still saved to `campaigns/{slug}/strategy/operator-consultations/{name}.md`. Only the invocation API differs.

### BREAKING : Direct invocation of sub-skills no longer works

If you were invoking `/promote:welsh-linkedin`, `/promote:hormozi`, etc. directly in v1.1.0, this no longer works in v1.2.0. Use `promote-strategist` (which orchestrates all 37 internals via Read+Task) or fork the plugin and adapt.

### Restructure summary

- **Moved** : 37 directories `skills/promote-*/` → `prompts/{category}/{name}/`
  - 16 operators v1.1 → `prompts/operators/`
  - 1 channel-strategist → `prompts/orchestrators/`
  - 9 personas (Hormozi, Ammar, Paul Graham, X-Mastery, MrBeast, Steve Jobs, Schwartz, Holiday, Gerhardt-Founder) → `prompts/personas/`
  - 8 frameworks (JTBD, Dunford, Cialdini, Voss, Four-Fits, PLG, GEO, AI-Content) → `prompts/frameworks/`
  - 2 tactical (customer-research, pricing-strategy) → `prompts/tactical/`
  - 1 utility (huashu-nuwa) → `prompts/utility/`
- **Renamed** : `SKILL.md` → `prompt.md` in all 37 dirs. Removed `name:` field from frontmatter (no longer skills).
- **Kept in `skills/`** : `promote-strategist`, `promote-content-batcher` (the 2 exposed entry points).
- **install.sh** : now creates 2 symlinks (vs 39 in v1.1.0).
- **content-production.md** : routing table updated (skill names → file paths).
- **delegation-matrix.md** : cascade pattern Read+Task documented (replaces v1.1.0 cascade `/skill:name`).
- **plugin.json + marketplace.json** : version 1.2.0, descriptions updated.

### Migration

Existing campaigns continue to work (artifacts under `campaigns/{slug}/` are untouched). New campaigns use the v1.2.0 invocation pattern automatically. To upgrade an existing v1.1.0 campaign: re-run `promote-strategist --resume`. The strategist detects that operator consultations exist and consumes them via the new pattern.

### Cleanup possible if Anthropic adds official `internal: true` flag

If Claude Code 2026/2027 ships an official mechanism (e.g., `internal: true` in SKILL.md frontmatter), migration back is trivial: `mv prompts/{category}/{name}/ skills/promote-{name}/` + add `name:` and `internal: true` to frontmatter. v1.2.0 is reversible.

---

## [1.1.0] — 2026-04-29

Major release based on real-test feedback (v1.0.0 deployed and tested on a real product). Two structural gaps were identified:
1. **Outputs not exploitable for an executor agent** — calendar was a skeleton (status=draft slots without title/body/asset specs).
2. **Channel myopia** — the strategy only proposed channels the user explicitly mentioned (no email, no podcast, no founder-led, no GEO/SEO).

v1.1.0 fixes both via two-pass orchestration (consultation + production), 17 new world-class operator skills, 8 new tactical frameworks, 2 new orchestrator skills, and a refactored P3 strategy synthesis pipeline.

### Added — 17 new operator skills (sub-school D, persona-incarnée)

**10 new organic operators** (5-7 hand-picked based on exhaustive research) :
- `promote-welsh-linkedin` (Justin Welsh — LinkedIn B2B, $5M+ solo) — 448 lines
- `promote-mcgarry-newsletter` (Matt McGarry — Newsletter paid acq, $20M+ tracked) — 529 lines
- `promote-gerhardt-founder` (Dave Gerhardt — Founder-led B2B cross-channel) — 306 lines
- `promote-indig-geo-seo` (Kevin Indig — SEO/GEO 2026, ex-Shopify Director) — 486 lines
- `promote-hormozi-shortform` (Alex Hormozi — TikTok/Reels/Shorts, $100M Leads) — 391 lines
- `promote-lenny-substack` (Lenny Rachitsky — Substack premium, $1.5M+ ARR) — 530 lines
- `promote-ferriss-podcast` (Tim Ferriss — Podcast host method, 1B+ downloads) — 727 lines
- `promote-robinson-outbound` (Adam Robinson — Cold/Warm B2B, RB2B $5M ARR) — 540 lines
- `promote-isenberg-community` (Greg Isenberg — Discord/community, Late Checkout $10M/yr) — 538 lines
- `promote-johnson-instagram` (Brock Johnson — Instagram organic, 892K followers + 45K students) — 399 lines

**7 new paid operators** :
- `promote-faris-meta-and-fundamentals` (Andrew Faris — Meta Ads + paid fundamentals transverse, $100M+ géré) — 587 lines
- `promote-wilcox-linkedin-ads` (AJ Wilcox — LinkedIn Ads, **$150-200M LinkedIn ad spend documented**) — 497 lines
- `promote-ryan-pmax` (Mike Ryan — Google PMax/Shopping, "PMax Whisperer", €500M+/an) — 558 lines
- `promote-vallaeys-google` (Frederick Vallaeys — Google Search/PPC + AI Max, ex-Google insider) — 530 lines
- `promote-seufert-mobile-attribution` (Eric Seufert — Mobile UA + post-iOS14 attribution) — 573 lines
- `promote-sanchez-tiktok` (Savannah Sanchez — TikTok/Snapchat Ads, 200+ ads/sem, 50+ clients) — 453 lines
- `promote-curry-amazon-youtube` (Brett Curry — Amazon Ads + YouTube Ads, 100+ DTC brands) — 515 lines

All 17 operators support **dual mode** : Mode CONSULTATION (used in P3.C strategist) + Mode PRODUCTION (used in P4 + content-batcher). Pattern compliance ≥14/15 each.

### Added — 2 new orchestrator skills

- `promote-channel-strategist` (sub-école A mini) — Proposes channels ACTIVELY (beyond user-mentioned), invokes operators in strategic-consultation mode, arbitrates inter-operator conflicts, produces final mix with primary/secondary/deferred/excluded categorization. Solves the v1.0.0 channel myopia gap.
- `promote-content-batcher` (sub-école C scoped surgeon) — Converts outline-status calendar slots into concrete posts on demand (J+14, J+28, J+42, etc.). Re-reads operator strategic consultations from P3.C. Idempotent.

### Added — 8 new framework references

**5 organic frameworks** :
- `references/channel-reddit.md` (Reddit organic — tactical playbook)
- `references/channel-hn-and-launches.md` (HN + Product Hunt + Indie Hackers)
- `references/channel-facebook.md` (Facebook organic — light, declining channel)
- `references/channel-pinterest-organic.md` (Pinterest organic — niche verticals)
- `references/channel-emerging-platforms-2026.md` (Threads + Bluesky + Mastodon + WhatsApp + Telegram)

**3 paid frameworks** :
- `references/channel-paid-x-reddit-pinterest.md` (X Ads + Reddit Ads + Pinterest Ads — paid niches grouped)
- `references/channel-paid-emerging-2026.md` (CTV/OTT + TikTok Shop + Walmart Connect + DOOH — WAIT v1.2 operators)
- `references/channel-paid-other-niches.md` (Affiliate + B2B sponsorships + Podcast Ads + Email Ads sponsorships)

### Added — Support files

- `references/content-production.md` — factorisation logique production multi-canal (channel→operator routing table, post format, quality gates). Consumed by P4 strategist + content-batcher.
- `templates/post.md.template` — standard format for produced posts.

### Changed — promote-strategist refactored (v1.0.0 → v1.1.0)

**P3 Strategy Synthesis** split in 7 sub-phases :
- **P3.A** — Foundations (Rumelt, JTBD, Positioning, Hormozi, Schwartz, Ammar, Four-Fits, PLG, Cialdini-read, Paul Graham)
- **P3.B** — Channel Mix Initial (NEW : `promote-channel-strategist` proposes mix)
- **P3.C** — Strategic Consultation (NEW : invokes each operator in consultation mode, saves to `strategy/operator-consultations/`)
- **P3.D** — Mix Refinement & Conflict Resolution (NEW : channel-strategist arbitrates)
- **P3.E** — Pillars + Cadence + Voice consolidation
- **P3.F** — GEO + Instrumentation strategic consultation (Indig, Faris, Seufert)
- **P3.G** — Rumelt validator AVAL

**P4 NEW : Content Production 14-day** — produces concrete posts for J0-J13 using operators in PRODUCTION mode.

**P5 (renamed from P4 in v1.0.0)** — Packaging.

**Intake** : Q5.5 enriched ("what's existing AND what to explore"), Q5.7 added (product type).

**Delegation matrix** : v1.0.0 single-cascade replaced by sub-phase-routed cascade (per `references/content-production.md`). Conflict resolution matrix documented.

**Templates updated** :
- `STATE.yaml.template` : new fields `concrete_posts_count`, `outlines_count`, `posts_directory`, `operator_consultations_completed`.
- `11-content-calendar-90d.csv.template` : columns now `date,channel,pillar,format,title,body_outline,body_path,assets_path,status` (status=outline|concrete|posted|archived).
- `handoff-to-executor.yaml.template` : new sections `content`, `channel_distribution`, `operator_consultations`.
- `06-distribution-plan.md.template` : new sections "Channels considered but DEFERRED", "Tradeoffs résolus".
- `strategy-summary.md.template` : new sections "Tradeoffs résolus", "Content production status".

### Volume

- **Skills total** : 39 (20 v1.0.0 + 17 new operators + 2 new orchestrators)
- **References total** : 20 (11 v1.0.0 + 8 new framework refs + 1 content-production.md)
- **Lines of new SKILL.md content** : ~8,500 lines across 19 new skills

### Notes

- All v1.1.0 operators have explicit `feasibility_score`, `strategic_recommendations`, `cadence_proposed`, `content_pillar_adjustments`, `prerequisites_or_blockers`, `anti_patterns`, `recommended_skip_or_defer` schemas in their CONSULTATION mode output. This is the contract that makes the orchestration deterministic.
- Audit autonomy : 0 absolute paths in operator skills, 0 non-prefixed cross-skill invocations.
- Cost per campaign : ~80-120K tokens (vs 30-50K v1.0.0). Justification : transformation from "skeleton generator" to "multi-expert consultant".
- Part 2 (`promote-executor`) remains in development. v1.1.0 makes the executor less urgent because content batcher + concrete content production cover most of what was previously deferred.

### Migration from v1.0.0

Existing campaigns continue to work. New campaigns use the v1.1.0 pipeline automatically. To upgrade an existing campaign (re-run with new operators consulted):
1. Re-run the strategist with `--resume` mode.
2. The strategist will detect missing P3.C consultations and trigger them.
3. P4 will produce concrete content for J0-J13.
4. `promote-content-batcher` can then be invoked at J+14 to convert outlines.

---

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
