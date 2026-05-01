# Changelog

All notable changes to promote (the `promote` plugin).

## [1.4.0] — 2026-05-01 — **BREAKING — Source-Truth Ledger + Single-Run**

### Why this release

Real-test feedback after v1.3.0 ran on the same campaign livre. Two new structural problems surfaced :

1. **Le ledger n'a pas la bonne ground truth.** Verbatim user : *"soyons logique que pour un post sensé promouvoir un livre, cela n'a aucun sens que ce post contienne une autre histoire que le contenu du livre."* — Specific cases observed :
   - `operator-consultations/robinson-outbound.md` proposes a template DM saying *"chapitre 3 de mon livre"* — there's no Chapter 3 in the ledger, this is a fabrication. Quality Gate #7 v1.3.0 didn't catch it because the template DM was never produced as a final post (latent fabrication).
   - `verified-claims.csv` C029 listed 3 chapters ("prospection", "chiffrage industriel", "RH") inferred from author's batch interview answers — not validated TOC.
   - The intake P1 asks ZERO questions about table of contents / structure.
   - Insight : **the product itself** must be the source-of-truth, not the author's interview about the product.

2. **Content-batcher complicates without practical value.** Verbatim user : *"il n'y a pas besoin d'économiser, je veux que strategist produise les post de la plage de temps prévue."* — Token analysis confirmed : feedback loop J+14 / pivot strat / idempotence reasons for keeping batcher were theoretical (never used in v1.3.0 campaign). Simplification > marginal token savings.

### What v1.4.0 delivers (2 modules of patches)

#### 10.A — Source-Truth Ledger

- **NEW phase P0.5 — Product Content Ingestion** between P0 and P1. NEW subagent `prompts/utility/product-content-ingester/prompt.md` dispatches based on `product_type` (book/saas/course/service/hybrid) :
  - `book` → Amazon Look Inside crawl / publisher page / ASK USER for TOC + chapter summaries.
  - `saas` → multi-WebFetch on docs/features/pricing/changelog.
  - `course` → course landing crawl / ASK USER for syllabus.
  - `service` → ASK USER for offer descriptions + cases.
- Output : `intake/product-content.md` (markdown structured) — becomes the source-of-truth for STRUCTURE+EXAMPLES claims.
- **NEW claim categories** : `STRUCTURE` (chapter/module/feature names) and `EXAMPLES` (cases/anecdotes/quotes) — sourced EXCLUSIVELY from `intake/product-content.md` (NEVER inferred from author interviews).
- **`prompts/utility/claims-extractor/prompt.md` patched** : reads `product-content.md` for STRUCTURE/EXAMPLES, refuses to extract these from batches.
- **`prompts/utility/fact-checker/prompt.md` patched** : Quality Gate #7 enriched with 3 NEW sub-checks :
  - **#7.1 Product grounding** : if `category=PRODUCT_PROMOTION`, require ≥1 STRUCTURE/EXAMPLES claim_id traced. SOFT-FAIL if not — "post not grounded in product content, adjacent story not allowed".
  - **#7.2 Structural reference match** : chapter/module/feature names must match a STRUCTURE claim. REJECT_IMMEDIATE if not. Hard fail (no retry). v1.4.0 fix for v1.3.0 robinson-outbound bug.
  - **#7.3 Anecdote source** : specific persons/cases/scenarios must match EXAMPLES claim or have explicit attribution + PROCESS claim. SOFT-FAIL if not.
- **`references/anti-fabrication-contract.md` enriched** with Product-Promotion Constraint section (3 new rules : Règles 5-6-7).
- **34 internal prompts patched** (16 operators + 9 personas + 8 frameworks + 1 orchestrator) : v1.3.0 contract block replaced with v1.4.0 dual contract block (Anti-Fabrication + Product-Promotion).
- **Operator-consultations P3.C** : new field `must_quote_from` (claim_ids of STRUCTURE/EXAMPLES the pillar must ground in). Mandatory non-empty for PRODUCT_PROMOTION pillars.
- **Default `never-claims.txt.template` enriched** with v1.4.0 entries blocking chapter/module/case fabrication.

#### 10.B — Single-Run Production (delete content-batcher)

- **DELETE** `skills/promote-content-batcher/` entirely.
- **Strategist P4 patched** : produces the full configured window (default 90 days, configurable `--days N` flag) in ONE RUN. NO MORE `status='outline'` at delivery — every slot ends as `concrete` or `manual_review_needed`.
- **Atomization variants library extended** from 10 to 15 variants (`references/content-production.md`) with rotation state in `STATE.yaml.atomization_history` to support 30+ atoms per pillar over 90 days.
- **Calendar template renamed** : `11-content-calendar-14d-then-outline.csv` → `11-content-calendar-Nd-full.csv`. New columns: + `category` (PRODUCT_PROMOTION | INDUSTRY_PERSPECTIVE).
- **`install.sh`** : 1 symlink (`promote-strategist` only). Was 2 in v1.3.0.
- **Manifests v1.4.0** : 1 skill exposed.
- **`STATE.yaml.template` enriched** with `product_type`, `product_content_path`, `product_content_completeness`, `atomization_history`, `window_days`.
- **`handoff-to-executor.yaml.template` enriched** with `product_content_path`, `product_content_completeness`, `full_window_concrete_count`, `manual_review_needed_count`, `grounding_check_pass_rate`, `schema_version: v1.4.0-full-window`.
- **30-point completeness checklist** (was 28 v1.3.0) : NEW Section M (source-truth grounding, 2 points).

### BREAKING migration impact

If you had v1.3.0 campaigns running, you will need to :

1. Re-run P0.5 manually : invoke the product-content-ingester subagent on existing campaigns to generate `intake/product-content.md`.
2. Re-run P1.5 to extract STRUCTURE+EXAMPLES claims from product-content.md.
3. The content-batcher skill is GONE. If you were invoking `/promote:promote-content-batcher`, that no longer works. Use `/promote:promote-strategist <url>` (or `--resume` mode) which now produces the full window.
4. Calendar schema changed (`14d-then-outline` → `Nd-full`, new `category` column, no more outline status).

### Token budget v1.4.0 vs v1.3.0

- v1.3.0 single-run (14d) + 5 batchers : ~2.5M tokens cumulés sur 90j.
- v1.4.0 single-run 90d : ~1.6-2.0M tokens.
- Net : économies modestes sur full window (~20-30%), simplicité majeure (1 entry point, 1 invocation, no manual batcher re-runs).

User accepted token cost : *"il n'y a pas besoin d'économiser, je veux que strategist produise les post de la plage de temps prévue."*

### Files added

- `prompts/utility/product-content-ingester/prompt.md` (NEW subagent)
- `skills/promote-strategist/templates/product-content.md.template`

### Files removed

- `skills/promote-content-batcher/` (entire directory : SKILL.md + references/)
- `skills/promote-strategist/templates/11-content-calendar-14d-then-outline.csv.template` (renamed)

### Files renamed

- `skills/promote-strategist/templates/11-content-calendar-14d-then-outline.csv.template` → `11-content-calendar-Nd-full.csv.template`

### Files modified (substantial)

- `references/anti-fabrication-contract.md` (Product-Promotion Constraint section + Règles 5-6-7)
- `references/content-production.md` (3 NEW Quality Gate #7 sub-checks + atomization 15 variants + post category PRODUCT_PROMOTION/INDUSTRY_PERSPECTIVE)
- `prompts/utility/claims-extractor/prompt.md` (STRUCTURE/EXAMPLES categories + read product-content.md)
- `prompts/utility/fact-checker/prompt.md` (3 NEW sub-checks #7.1/#7.2/#7.3 + 7 moves vs 4)
- `skills/promote-strategist/SKILL.md` (P0.5 added, P4 single-run, drops outline status)
- `skills/promote-strategist/references/{pipeline-phases,delegation-matrix,intake-questions,completeness-checklist}.md`
- `skills/promote-strategist/templates/{STATE.yaml,handoff-to-executor.yaml,never-claims.txt}.template`
- All 34 internal prompts under `prompts/` (v1.3.0 contract → v1.4.0 dual contract)
- `install.sh` (1 symlink)
- `.claude-plugin/{plugin,marketplace}.json` (1.4.0)
- `README.md` (v1.4.0 workflow + P0.5 + single-run mention)

---

## [1.3.0] — 2026-05-01 — **BREAKING — Quality + Verification + Lean**

### Why this release

Real-test feedback after v1.2.0 ran on the campaign `amazon-fr-dp-b0gx2zpnyq` (François' book "L'IA au boulot"). Four structural problems surfaced :

1. **Hallucinations factuelles** : ~30-40% of posts contained ≥1 factual claim about the author/process that was not in the intake. Worst case : a Substack post invented "6 months of writing without AI", "12 chapters jetés", "samedi matin novembre café froid" — the author had NEVER attempted to write without AI. The pipeline had **0 factuality gates** ; the 6 quality gates v1.2.0 checked form (length, voice, anti-patterns) but not substance.
2. **Posts pas compelling** : 5 patterns of failure (factual hooks instead of emotional, mechanical atomization repetition, urgency-less CTAs, no "why listen to me" anchor, no Schwartz awareness routing). Best posts (Substack 8/10) were also worst hallucinators.
3. **Mix contenu/metadata** : ratio ~50/50 in each post.md. Worst cases at 19-28% pure content (templates with `{...}` placeholders never filled).
4. **Coût/valeur orchestration** : P3 = 23% of tokens (348K), but 4 artefacts (`09-geo-plan.md` + full `10-instrumentation.md` + `11-content-calendar-90d.csv` detailed + `p3g-rumelt-aval.md`) had ~0% downstream impact on P4 content production = pure theater.

### What v1.3.0 delivers (5 modules of patches)

#### 9.A — Verified Claims Ledger + Quality Gate #7 (factual claims check)

- **NEW phase P1.5 — Claims Extraction & Validation** between P1 and P2. The new `prompts/utility/claims-extractor/prompt.md` subagent extracts factual claims from intake into `intake/verified-claims.csv` (columns : `claim_id, claim_text, source_batch, source_quote, category, confidence, verified_by_user`). User reviews in 15 min (mode guided) ; mode autopilot auto-validates HIGH-confidence claims.
- **NEW `intake/never-claims.txt`** : user-curated list of forbidden phrasings. Quality Gate #7 reject_immediate any post matching semantically.
- **NEW Quality Gate #7 (factual claims check)** : `prompts/utility/fact-checker/prompt.md` subagent cross-checks every claim in produced posts against the ledger. Sources accepted : (a) `claim_id` from CSV, (b) public verifiable fact, (c) explicit attribution marker. Verdict : ship / retry_with_ledger_constraints / manual_review_needed.
- **NEW `references/claims-ledger-spec.md`** : full format + lifecycle + extraction rules + validation rules.
- **NEW `references/anti-fabrication-contract.md`** : binding contract injected by reference into all 34 internal prompts.

#### 9.B — Operator prompt hardening (anti-fabrication + voice fidelity)

- **All 34 internal prompts** (16 operators + 9 personas + 8 frameworks + 1 orchestrator) now contain the `## Anti-Fabrication Contract` section, bound to `references/anti-fabrication-contract.md`.
- **Welsh-LinkedIn patch** : added Hook variants library (10 variants), Atomization rotation rule (consume prior `.meta.yaml` to enforce variant diversity), Compelling content rules (5 patches: hook=sentiment-first, atom rotation, urgency CTA, why-listen anchor, reader-honesty target).
- **Lenny-Substack patch** : added Narrative arc rules (5 rules) explicitly addressing the v1.2.0 hallucination. Default is now Option B `from-day-1-with-method arc` ; Option A `failure-pivot arc` requires ledger confirmation. "Show your prompts" must be REAL prompts. Sensory details require source.

#### 9.C — Compelling content patches

- **NEW Quality Gate #8 (reader-honesty)** : `prompts/utility/reader-honesty-judge/prompt.md` audits reader-first vs author-first ratio. Threshold by awareness_stage (unaware ≥80% ... most-aware ≥60%). Below threshold = retry / manual_review.
- **Atomization variants library (10 variants)** in `references/content-production.md`. Rotation rule enforced by Quality Gate #4 (atomization-mechanical-repeat detection).
- **Schwartz awareness routing** : `awareness_stage` becomes a mandatory column in calendar. Distribution rule : max 30% per stage on the 14d concrete window.

#### 9.D — Output schema split (.md pure content + .meta.yaml metadata)

- **`content/posts/{slug}.md`** : pure copy-paste-ready content. NO metadata, NO `{...}` placeholders allowed (Quality Gate #1 reject-on-placeholder hard FAIL).
- **`content/posts/.meta/{slug}.yaml`** : full metadata audit (asset specs, posting metadata, gate audits, voice notes, factual_claims_used, narrative_gaps_to_fill, atomization_variant_used, tokens_used).
- **NEW `templates/post.meta.yaml.template`** : the metadata schema.

#### 9.E — Aggressive trim P3 (-25% tokens)

- **CUT** `strategy/09-geo-plan.md` entirely (defer to standalone `promote-geo-strategist` v1.3.1+).
- **CUT** `strategy/p3g-rumelt-aval.md` by default (opt-in via `--rumelt-aval` flag, renamed `p3f-rumelt-aval.md`).
- **TRIM** `strategy/10-instrumentation.md` (full 8-tripwires) → `strategy/10-tripwires-top3.md` (3 KPIs only).
- **TRIM** `strategy/11-content-calendar-90d.csv` (90 detailed) → `strategy/11-content-calendar-14d-then-outline.csv` (14d concrete + 76d minimal outline).
- **Net P3 economy** : ~105K tokens out, ~70-140K tokens in for new gates #7+#8 = neutral or slightly reduced.

### BREAKING migration impact

If you had v1.2.0 campaigns running, you will need to :

1. Re-run P1.5 manually : invoke the claims-extractor subagent on existing intake to generate `verified-claims.csv` + initialize `never-claims.txt`. The strategist v1.3.0 in `--resume` mode handles this.
2. Existing `content/posts/{slug}.md` files mix content + metadata. They will work as-is for `promote-executor` later, but for new posts the schema split applies. Optional migration script.
3. Existing `09-geo-plan.md` + full `10-instrumentation.md` + `p3g-rumelt-aval.md` artefacts in v1.2.0 campaigns are kept untouched. New campaigns won't generate them.
4. `11-content-calendar-90d.csv` schema change : new columns `awareness_stage, body_path, meta_path` (instead of `title, body_outline, body_path, assets_path`). Old calendars need migration if you want to use content-batcher v1.3.0.

### Token budget v1.3.0 vs v1.2.0

- v1.2.0 total : ~1.51M tokens per campaign
- v1.3.0 total : ~1.2-1.3M tokens per campaign
- **Net reduction : 15-20% at higher quality**

### Files added

- `references/anti-fabrication-contract.md`
- `references/claims-ledger-spec.md`
- `prompts/utility/claims-extractor/prompt.md`
- `prompts/utility/fact-checker/prompt.md`
- `prompts/utility/reader-honesty-judge/prompt.md`
- `skills/promote-strategist/templates/post.meta.yaml.template`
- `skills/promote-strategist/templates/verified-claims.csv.template`
- `skills/promote-strategist/templates/never-claims.txt.template`

### Files removed

- `skills/promote-strategist/templates/09-geo-plan.md.template`

### Files renamed

- `skills/promote-strategist/templates/10-instrumentation.md.template` → `10-tripwires-top3.md.template`
- `skills/promote-strategist/templates/11-content-calendar-90d.csv.template` → `11-content-calendar-14d-then-outline.csv.template`

### Files modified (substantial)

- `references/content-production.md` (gates #7+#8, output schema split, atomization variants)
- `skills/promote-strategist/SKILL.md` (P1.5 added, P3 trimmed from 7 to 5 sub-phases)
- `skills/promote-strategist/references/{pipeline-phases,delegation-matrix,intake-questions,completeness-checklist}.md`
- `skills/promote-strategist/templates/{post.md,handoff-to-executor.yaml}.template`
- `skills/promote-content-batcher/SKILL.md` (Move 4 split + fact-check)
- All 34 internal prompts under `prompts/` (anti-fabrication contract injected by reference)
- `prompts/operators/welsh-linkedin/prompt.md` (specific patches)
- `prompts/operators/lenny-substack/prompt.md` (specific patches)
- `.claude-plugin/{plugin,marketplace}.json` (1.3.0)
- `README.md` (mention v1.3.0 + ledger workflow + schema split)

---

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
