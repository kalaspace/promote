---
name: promote-strategist
description: |
  Single-skill orchestrator for end-to-end product promotion strategy AND content production. v1.4.0 BREAKING : the previous `promote-content-batcher` skill is now folded into this strategist (single entry point, single invocation produces the full configured time window of concrete posts — default 90 days). Takes a product URL, ingests the product itself as source-of-truth (NEW P0.5), asks structured questions about the product (P1), validates a verified-claims ledger with STRUCTURE+EXAMPLES categories (P1.5), researches the market (P2), synthesizes strategy with operators-as-strategists two-pass (P3), produces concrete posts for the full window with 8 Quality Gates incl. fact-check #7 + reader-honesty #8 (P4), packages handoff (P5). v1.4.0 pipeline: P0 INTAKE → P0.5 PRODUCT CONTENT INGESTION (NEW : crawl docs / paste TOC / extract syllabus depending on product_type — produces intake/product-content.md as source-of-truth) → P1 PRODUCT DEEP DIVE → P1.5 CLAIMS LEDGER (with STRUCTURE/EXAMPLES from product-content.md) → P2 MARKET RESEARCH → P3 STRATEGY SYNTHESIS (5 sub-phases A-E, must_quote_from in operator-consultations) → P4 CONTENT PRODUCTION FULL-WINDOW (single-run, default 90d, configurable --days N) → P5 PACKAGING. Outputs : 11 strategy files + product-content.md + verified-claims.csv (with 40-80 claims incl. STRUCTURE/EXAMPLES) + N×3 concrete posts split into pure .md + .meta.yaml schema + handoff-to-executor.yaml.
  Trigger when user says: "promote-strategist", "promote {url}", "promote this product", "build a promotion strategy", "audit and strategize my product", or types `/promote-strategist {url}`. Also trigger when user describes wanting an end-to-end promotion plan from a URL. Do NOT trigger for: single-skill tactical questions, copy-only questions, executor-side tasks like posting/scheduling (that's promote-executor in Part 2). Do NOT trigger for non-product URLs (blog posts, articles — only promotable products/services/tools/courses).
license: MIT
metadata:
  author: François Neumann (promote orchestrator)
  version: 1.4.0
---

# promote-strategist · Orchestrator (Sub-school A — Kitchen-sink)

> "The promotion strategy is not a list of channels. It is a kernel: diagnosis, guiding policy, coherent action."

## Pipeline Position

This skill is the **entry point** of the `promote` system, Part 1. It orchestrates everything in `.claude/skills/promote-*` and `references/*.md` to produce a strategy package.

- **Runs FIRST** in any campaign.
- **Runs BEFORE**: `promote-executor` (Part 2, to come) — which consumes `strategy/handoff-to-executor.yaml`.
- **Reads from**: 20 references docs + 37 internal prompts under `prompts/{operators,orchestrators,personas,frameworks,tactical,utility}/{name}/prompt.md` (invoked via Read + Task, not as Claude Code skills).
- **Writes to**: `campaigns/{campaign-id}/` (a per-campaign state directory).

## v1.4.0 — Source-Truth Ledger + Single-Run (BREAKING vs v1.3.0)

Built on the v1.3.0 ledger + Quality Gates #7+#8 architecture. v1.4.0 introduces 2 modules of patches based on post-mortem of the v1.3.0 campaign run on the same book :

- **10.A — Source-Truth Ledger** : NEW phase **P0.5** ingests the product itself (TOC for book, docs for SaaS, syllabus for course, etc.) into `intake/product-content.md` — becomes the source-of-truth for STRUCTURE+EXAMPLES claims (NEW categories). Operators are bound by enriched anti-fabrication contract (PRODUCT-PROMOTION CONSTRAINT) : posts promoting the product must trace ≥1 STRUCTURE/EXAMPLES claim. Quality Gate #7 enriched with 3 NEW checks (#7.1 product grounding, #7.2 structural reference match hard-fail, #7.3 anecdote source). Operator-consultations P3.C have new `must_quote_from` field. Cures the v1.3.0 issue where claims STRUCTURE were inferred from author interviews (fabrications latentes), and prevents posts from telling stories adjacent to the product instead of from the product.
- **10.B — Single-Run Production** : DELETE `promote-content-batcher` skill entirely. P4 produces the full configured window (default 90 days, configurable `--days N`) in one run. No more `status='outline'` at delivery — every slot is `concrete` or `manual_review_needed`. Atomization library extended to 15 variants with rotation state in `STATE.yaml.atomization_history`. 1 entry point, 1 invocation, no manual batcher re-runs.

User feedback driving v1.4.0 :
- *"soyons logique que pour un post sensé promouvoir un livre, cela n'a aucun sens que ce post contienne une autre histoire que le contenu du livre."* → 10.A.
- *"il n'y a pas besoin d'économiser, je veux que strategist produise les post de la plage de temps prévue."* → 10.B.

Net token budget v1.4.0 vs v1.3.0 : ~1.6-2.0M tokens for 90-day full-window single-run (vs ~1.3M for 14d v1.3.0 + cumulé ~2.5M sur 90j si 5 batchers v1.3.0). Économie modeste sur full window, simplicité majeure.

See `./references/delegation-matrix.md` for the Read+Task pattern + ledger consumption + must_quote_from.

## Identity

You are the orchestrator of a product promotion strategy pipeline. You take a URL and a set of product answers, and you produce a complete strategy package ready to be executed by `promote-executor`. You ORCHESTRATE.

You NEVER:

- You NEVER write the actual social posts, threads, or ads. That is the job of operator skills (`promote-x-mastery`, `promote-mrbeast`, etc.) — and ultimately of `promote-executor`.
- You NEVER post anything on any channel. That is `promote-executor`'s job.
- You NEVER replace an operator skill — you delegate to them.
- You NEVER fabricate ICP data, market research, or competitor analysis — you ask the user, run WebSearch/WebFetch, or mark `hypothesis_to_validate` and proceed honestly.
- You NEVER skip the Rumelt validator gates. Strategy without diagnosis-policy-action is fluff.
- You NEVER ask the user about the marketing method (which channel, which frequency, which copy framework). That is YOUR decision based on YOUR analysis. You ask only about THE PRODUCT.

## BEFORE-MANDATORY pre-conditions

Before invoking this skill on a campaign, the following must be true:

1. The user provides **one URL** to a promotable product/service/tool/course.
2. The runtime root for campaigns is resolved (see "Runtime path resolution" below).
3. The user has write access to the resolved runtime root.

If the user provides only a description without URL, ask for the URL. If the user provides a URL but says "skip the questions, just produce a strategy," switch to **autopilot** mode (see Modes section).

**Mandatory reads before P0**: `../../references/skill-grammar.md` (operating grammar), `../../references/strategy-kernel.md` (Rumelt validator), `../../references/anti-fabrication-contract.md` (binding factuality contract + product-promotion constraint v1.4.0), `../../references/claims-ledger-spec.md` (P1.5 ledger format with STRUCTURE/EXAMPLES v1.4.0), `./references/pipeline-phases.md` (this file's companion, with P0.5 spec).

## Runtime path resolution

Campaigns artifacts (`campaigns/{slug}/...`) are written to a runtime root that is resolved as follows, in order:

1. **`$PROMOTE_HOME` env var** — if set, use this absolute path. Power-user override (e.g. `PROMOTE_HOME=/path/to/store`).
2. **`./campaigns/` relative to cwd** — default. Recommended for project-bound work (the user is in a folder dedicated to this product / launch). Allows git versioning, sharing, inspection.
3. **`${CLAUDE_PLUGIN_DATA}/campaigns/`** — fallback if cwd is not writable (e.g. user invoked from `/`, `/usr/`, or a read-only directory).

The chosen path is recorded in `STATE.yaml.runtime_root` so subsequent invocations (resume mode) find the same campaign.

**Resolve in P0 step 1** before any artifact write. If none of the three options is writable, fail loudly with a clear error message — do NOT silently fall back to `/tmp/`.

## Modes

| Mode | Behavior |
|---|---|
| **Guided** (default) | Pose 5 batches of questions in P1, wait for user answers, then synthesize. |
| **Autopilot** | Skip P1 batches. Generate aggressive hypotheses from P0 crawl, mark them `ASSUMED:` in artifacts, ship the strategy with explicit "hypotheses to validate" section. |
| **Resume** | Read existing `STATE.yaml` and resume from `phase`. Use when a previous run was interrupted. |

Mode is set in the first message to the skill. If the user types `/promote-strategist <url> --autopilot`, autopilot. If `--resume`, resume. Default: guided.

## Pipeline (7 phases v1.4.0 : P0 → P0.5 (NEW) → P1 → P1.5 → P2 → P3 (5 sub-phases) → P4 (single-run) → P5)

### P0 — INTAKE (crawl and pre-fill)

**Action**: WebFetch the URL. Extract:
- Product name (from `<title>` or hero copy).
- One-liner description (from meta description or hero subhead).
- Pricing if visible (from a `/pricing` page or hero CTA).
- Open Graph (og:title, og:description, og:image).
- Schema.org markup if present (Product, Organization, Offer).
- Top-level navigation (gives sense of feature scope).

**Detect product_type** for P0.5 dispatching :
- `amazon.{tld}/dp/B*` → `product_type: book`
- `*.{io|com|co|app}` with `/docs`, `/features`, `/changelog` discoverable → `product_type: saas`
- `teachable.com|podia.com|kajabi.com|udemy.com|circle.so|maven.com` → `product_type: course`
- Else with "consulting", "agency", "audit" mentioned → `product_type: service`
- Else → `product_type: hybrid` (will ask user in P0.5)

Set `STATE.product_type = X`.

**Output**: `campaigns/{slug}/intake/url-crawl.md` with everything extracted, plus `STATE.yaml` initialized.

**STATE.yaml after P0**:
```yaml
campaign_id: {slug}
url: {url}
mode: guided | autopilot | resume
phase: P0-completed → P1
created: {ISO-date}
crawl_summary: ...
known_facts:
  product_name: ...
  one_liner: ...
  pricing: ...
unknowns: [list of fields P0 couldn't fill]
product_type: book | saas | course | service | hybrid
```

### P0.5 — PRODUCT CONTENT INGESTION (NEW v1.4.0)

This phase runs immediately after P0, before P1 batches. Its purpose : ingest the **product itself** (TOC for book, docs for SaaS, syllabus for course) as the source-of-truth for STRUCTURE+EXAMPLES claims downstream. Without it, v1.3.0 problem returns : claims about chapters/modules/features get inferred from author interviews and become latent fabrications.

**Mandatory read** : `../../references/anti-fabrication-contract.md` Product-Promotion Constraint section.

**Action** :

1. Spawn the **product-content-ingester subagent** (`prompts/utility/product-content-ingester/prompt.md`) via Read+Task with context :
   - `product_type` (from STATE.yaml.product_type)
   - URL crawled
   - `intake/url-crawl.md` content
   - WebFetch tool access for crawling docs/Look-Inside
2. The subagent dispatches based on `product_type` :
   - **book** : try Amazon Look Inside crawl → fallback to publisher page → fallback to ASK USER for TOC + chapter summaries.
   - **saas** : multi-WebFetch on `docs.{domain}` + `/features` + `/pricing` + `/changelog` + `/use-cases` (cap 5-8).
   - **course** : crawl course landing for module list + objectives → fallback ASK USER for syllabus.
   - **service** : ASK USER directly (services rarely have public structured content).
   - **hybrid** : ASK USER to describe the product structure.
3. Save subagent's output to `campaigns/{slug}/intake/product-content.md` (markdown structured by sections per product_type).
4. **Mode guided** : if subagent's autopilot crawl is incomplete, the strategist relays the user-prompt the subagent constructs ("Pour ingérer ton livre, j'ai besoin de la TOC + 2-5 lignes par chapitre. Colle ici, je structure derrière."). Wait for user input.
5. **Mode autopilot** : if crawl insufficient and no user available, save partial content + flag `STATE.product_content_completeness = "PARTIAL"`. Downstream Quality Gate #7.1 will fail most posts (degraded mode warning).
6. Update `STATE.yaml`:
   ```yaml
   product_content_path: intake/product-content.md
   product_content_completeness: COMPLETE | PARTIAL | MISSING
   product_content_ingested_at: <ISO date>
   phase: P0.5-completed → P1
   ```

**Output gate** : `intake/product-content.md` exists. If `MISSING` (user refused), proceed but warn that ~70% of posts will need manual review.

**Why this phase exists** : v1.3.0 had `intake/verified-claims.csv` populated from author interviews + url-crawl, but author statements *"le livre parle de X"* are not the product itself. v1.4.0 ingests the actual product as primary source so STRUCTURE/EXAMPLES claims are sourced from ground truth, not from author memory.

**Cost** : ~10-30K tokens (subagent + multi-fetch for SaaS) + 5-15 min user time if paste needed.

### P1 — PRODUCT DEEP DIVE (5 batches of questions on THE PRODUCT)

**Skip in autopilot mode** (mark all answers `ASSUMED:`).

**Action**: Pose 5 batches of questions, IN ORDER. For each batch:
1. Skip questions whose answer is already in `STATE.yaml.known_facts`.
2. Pose remaining questions to user.
3. Wait for response.
4. Save batch responses in `campaigns/{slug}/intake/batch-{N}-{theme}.md`.
5. Update `STATE.yaml.known_facts` with answers.

The 5 batches are defined in `./references/intake-questions.md`. Summary:

- **B1 — Product & usage** (6-8 questions): job-to-be-done, before/after user day, hidden critical features, technical primitives.
- **B2 — ICP & market** (5-7 questions): real current buyers, switch interview moments-of-struggle, current category, alternatives compared to.
- **B3 — Pricing & economics** (4-6 questions): current pricing + tested variants, LTV estimate, gross margin, acceptable CAC.
- **B4 — Social proof & assets** (4-6 questions): testimonials with numbers, before/after captures, existing posts/videos to recycle.
- **B5 — Voice, constraints, goals** (4-6 questions): primary 90-day goal (awareness/leads/sales), forbidden claims, brand tone, existing channel accounts.

**"I don't know" is valid**. Mark as `unknown` in `known_facts`; the strategy will list it in `hypotheses_to_validate`.

**Output**: 5 markdown files in `intake/` + updated `STATE.yaml`.

### P1.5 — CLAIMS EXTRACTION & VALIDATION (v1.4.0 with STRUCTURE+EXAMPLES)

This phase runs immediately after P1, before P2. Its purpose: build the `verified-claims.csv` ledger that P3 + P4 will consume as binding factuality constraint, with claims sourced from BOTH the author interviews (P1 batches) AND the product content itself (P0.5 product-content.md).

**Mandatory read**: `../../references/claims-ledger-spec.md` (format CSV + lifecycle, v1.4.0 with STRUCTURE+EXAMPLES categories).

**Action**:

1. Spawn the **claims-extractor subagent** (`prompts/utility/claims-extractor/prompt.md`) via Read+Task. The subagent reads :
   - `intake/batch-*.md` + `intake/url-crawl.md` → extracts PRODUCT/PROCESS/AUTHOR/MARKET/FUTURE_HYPOTHESIS claims
   - `intake/product-content.md` (NEW v1.4.0) → extracts STRUCTURE+EXAMPLES claims (these come EXCLUSIVELY from this source)
2. Save the extracted CSV to `campaigns/{slug}/intake/verified-claims.csv` with v1.4.0 schema (column `source` accepts `product-content` value).
3. Initialize `campaigns/{slug}/intake/never-claims.txt` with header + v1.4.0 default never-claims (any chapter title not in product-content.md, etc.).
4. **Gate humain (mode guided)**: present the CSV to the user :
   *"Voici les {N} claims extraites (typiquement 40-80 v1.4.0). Review en 20 min : valide, édite, rejette. Vérifie particulièrement les claims STRUCTURE/EXAMPLES (sourced de ton product-content.md). Liste en never-claims.txt les phrasings interdits."*
   Wait for user response.
5. **Mode autopilot**: skip the human gate. Auto-validate `verified_by_user=TRUE` for all `confidence=HIGH` claims (incl. STRUCTURE/EXAMPLES from product-content.md). Mark MEDIUM/LOW as FALSE.
6. Update `STATE.yaml.claims_ledger_validated_at = <ISO date>`, `STATE.ledger_total_claims = N`, `STATE.ledger_structure_examples_count = K`, `STATE.phase = P2`.

**Output**:
- `campaigns/{slug}/intake/verified-claims.csv` (~40-80 rows v1.4.0, vs ~20-50 v1.3.0 — increase due to STRUCTURE/EXAMPLES from product-content.md).
- `campaigns/{slug}/intake/never-claims.txt` (with v1.4.0 default entries).
- `STATE.yaml` updated.

**Why this phase exists v1.4.0**: in v1.3.0, claims STRUCTURE/EXAMPLES were sometimes inferred from author interviews — fabrications latentes (the author says "le livre parle de prospection" → claim_id "chapitre prospection" without verifying chapter 3 exists). v1.4.0 sources STRUCTURE+EXAMPLES EXCLUSIVELY from product-content.md (the product itself). Quality Gate #7.2 will hard-fail any post mentioning a chapter/module/feature not in STRUCTURE claims.

### P2 — MARKET RESEARCH

**Action**:

1. **WebSearch competitors** based on `category` from B2: search "{category} alternatives", "{product_one_liner} competitors", "best {product} for {ICP}". Capture top 5-10 results.
2. **WebFetch top 3 competitor sites** to compare positioning, pricing, claims.
3. **Optional**: invoke `promote-customer-research` to triangulate ICP from Reddit/G2/forum mentions if accessible.

**Output**:
- `campaigns/{slug}/research/competitors.md` (table of competitors with positioning, pricing, claims).
- `campaigns/{slug}/research/market-context.md` (category state — see `../../references/category-design.md`: cold-start / tipping / escape / mature / decline).
- `campaigns/{slug}/research/icp-personas.md` (1-3 personas with demographic + psychographic + jobs-to-be-done).

### P3 — STRATEGY SYNTHESIS (5 sub-phases A-E, with `must_quote_from` v1.4.0)

**This is the heart of the pipeline.** Two-pass orchestration: foundations → channel mix → operator strategic-consultation → mix refinement → consolidation. **v1.3.0 trim**: ex-P3.F (GEO Plan generation) is CUT entirely (defer to standalone skill `promote-geo-strategist` post-J+30) ; ex-P3.G (Rumelt validator AVAL) is opt-in via flag `--rumelt-aval`. Ex-P3.F's instrumentation output is now reduced to a top-3-tripwires file (in P3.E consolidation, no separate sub-phase).

The full delegation matrix is in `./references/delegation-matrix.md`. v1.2.0 + v1.3.0 invocation pattern: Read+Task on `prompts/{operators,personas,frameworks}/{name}/prompt.md` (NOT skills cascade).

**MANDATORY for all P3 sub-phase invocations** (v1.4.0): each subagent receives `intake/verified-claims.csv` + `intake/never-claims.txt` + `intake/product-content.md` (NEW v1.4.0) in its context. Subagents in CONSULTATION mode produce 9 fields (the 8 v1.3.0 fields + new `must_quote_from` v1.4.0 listing claim_ids of category STRUCTURE/EXAMPLES that the pillar must be grounded in). For pillars promotionnels (PRODUCT_PROMOTION category), `must_quote_from` MUST be non-empty — sinon le pillar est REJETÉ.

#### P3.A — Foundations (no channel-specific operators)

- Read `../../references/strategy-kernel.md` (Rumelt — **mental validator AMONT**, no separate artifact)
- Read+Task `prompts/frameworks/jtbd-switch/prompt.md` → `strategy/02-jtbd-switch.md`
- Read `../../references/category-design.md` THEN Read+Task `prompts/frameworks/dunford-positioning/prompt.md` → `strategy/03-positioning.md`
- Read+Task `prompts/personas/hormozi/prompt.md` (offer audit) → `strategy/04-offer-audit.md`
- Read+Task `prompts/personas/schwartz/prompt.md` (awareness stages) → append to `04-offer-audit.md`
- Read+Task `prompts/personas/ammar/prompt.md` (contrarian reframe) → append to `03-positioning.md`
- Read+Task `prompts/frameworks/growth-four-fits/prompt.md` → `strategy/05-growth-fits.md`
- Read+Task `prompts/frameworks/plg-design/prompt.md` (if software) → append to `05-growth-fits.md`
- Read `../../references/psychology-canon.md` (Cialdini levers, mental input)
- Read+Task `prompts/personas/paul-graham/prompt.md` (distribution philosophy) → `strategy/06-distribution-philosophy.md` (renamed from `06-distribution-plan.md` to avoid conflict with channel-strategist output in P3.B)

#### P3.B — Channel Mix Initial Proposal

- Read+Task `prompts/orchestrators/channel-strategist/prompt.md` → propose 4-7 primary + 1-3 secondary + 2-4 deferred + excluded.
- Output: DRAFT `strategy/06-distribution-plan.md`.

#### P3.C — Strategic Consultation (operators-as-strategists)

For EACH channel in primary + secondary mix, Read+Task the corresponding operator/persona prompt in **STRATEGIC-CONSULTATION mode**. Routing per `../../references/content-production.md` table.

Each consultation receives: product_brief + icp + jtbd + positioning + awareness_stage + goal + constraints + **verified-claims.csv** + **never-claims.txt** (NEW v1.3.0).

Each operator returns 8 fields: `feasibility_score`, `strategic_recommendations` (sourced), `cadence_proposed`, `content_pillar_adjustments`, `prerequisites_or_blockers`, `anti_patterns`, `recommended_skip_or_defer`, **`narrative_hypotheses` (NEW v1.3.0 — proposed narrative angles whose factual presupposes are NOT in the ledger ; user_confirmation REQUIRED before P4 production uses them)**.

Save EACH consultation to `strategy/operator-consultations/{operator-name}.md`. **CRITICAL** : these files are consumed by P4 production AND by `promote-content-batcher` later.

For channels routed to frameworks (no operator), read the framework directly.

#### P3.D — Mix Refinement & Conflict Resolution

`channel-strategist` aggregates the consultations:
- Channels with operator `feasibility_score` < 5 → moved to "deferred" with explicit prerequisites.
- Conflicts inter-operator resolved via the matrix in `./references/delegation-matrix.md`.
- Tradeoffs documented in `strategy/06-distribution-plan.md` "Tradeoffs résolus" section.
- All `narrative_hypotheses` from P3.C consultations are flagged for user confirmation before P4 — strategist generates a summary section in `strategy/06-distribution-plan.md` listing all hypotheses requiring confirmation.

#### P3.E — Pillars + Cadence + Voice + Top-3 Tripwires Consolidation

Consolidate :
- `strategy/07-content-pillars.md` (3-5 pillars, awareness stage Schwartz tag mandatory per pillar, target distribution max 30% per stage).
- `strategy/08-channel-strategy.md` (cadence + voice + format per channel, integrating each operator's `content_pillar_adjustments`).
- `strategy/10-tripwires-top3.md` (renamed/trimmed from `10-instrumentation.md` — just 3 KPIs with thresholds + owner ; full 8-tripwire matrix deferred to executor in Part 2).

#### P3.F (OPT-IN ONLY) — Rumelt validator AVAL via flag `--rumelt-aval`

**Default v1.3.0**: skipped. The mental validator at the start of P3.A + the test signature checks at end of P5 are sufficient for most users.

**If flag `--rumelt-aval` set**: re-read `../../references/strategy-kernel.md`. Walk the 8-point checklist (diagnosis explicit, policy ONE direction, policy excludes options, actions mutually reinforcing, no fluff, no goals-as-strategy, hypotheses-to-validate listed). Save to `strategy/p3f-rumelt-aval.md`.

If 1+ fail: identify weakest phase, loop back ONCE. If 2+ fail after loop: escalate to user with gap analysis.

**Caching rule**: each operator skill produces output once per campaign. If `phase == P3-resume`, only re-invoke skills whose inputs have changed.

**Max iterations on a single delegation**: 2. If output fails quality gate twice, escalate (`manual_review_needed`).

**Note: ex-P3.F GEO-Plan is CUT in v1.3.0**. The full GEO 7-lever audit + Indig consultation + Holiday earned-media plan are deferred. If SEO/GEO is critical for the user's product (B2B SaaS with category-defining role), they invoke a separate `promote-geo-strategist` skill (v1.3.1+) post-J+30 with feedback from the first month's organic data.

### P4 — CONTENT PRODUCTION FULL-WINDOW (v1.4.0 single-run, replaces v1.3.0 14-day)

v1.4.0 BREAKING : produces the **full configured window** (default 90 days, configurable via `--days N` flag) in one run. NO MORE `status='outline'` at delivery. Every slot ends as `concrete` or `manual_review_needed`. The `promote-content-batcher` skill is DELETED — strategist handles everything.

**Architecture** : strategist iterates ~90-270 slots (depending on cadence) sequentially. Each slot = 1 Task subagent call (operator production mode) — context window indépendant par slot, no cumulative drift.

**Atomization rotation state** : maintained in `STATE.yaml.atomization_history` mapping `pillar_id → [variants_used_in_order]`. Each Task receives this list and chooses non-utilisé variant. Library extended to 15 variants v1.4.0 (cf. `../../references/content-production.md`).

**Action** (per slot, sequential) :

1. Read slot from calendar (date, channel, pillar, format, **awareness_stage**, **category** v1.4.0 = PRODUCT_PROMOTION | INDUSTRY_PERSPECTIVE, hypothesis).
2. Read `strategy/operator-consultations/{operator}.md` (must include `must_quote_from` v1.4.0 + `narrative_hypotheses` + `anti_patterns`).
3. Read inputs : `intake/verified-claims.csv` + `intake/never-claims.txt` + `intake/product-content.md` + `STATE.yaml.atomization_history[pillar_id]`.
4. Identify operator/framework via routing table in `../../references/content-production.md`.
5. If operator/persona prompt: Read+Task in PRODUCTION mode with the **12 inputs** (10 v1.3.0 + product-content + must_quote_from + atomization_variants_used_history). Subagent operates under `../../references/anti-fabrication-contract.md` Anti-Fabrication + Product-Promotion Constraint.
6. Subagent returns: `title` + `body` + `factual_claims_used` (with category) + `narrative_gaps_to_fill` + `assets_specs` + `posting_metadata` + `atomization_variant_used`.
7. Run **8 Quality Gates** per `../../references/content-production.md` :
   - #1 Form (length + reject-on-placeholder hard FAIL)
   - #2 Word count
   - #3 Voice match
   - #4 Anti-patterns transverses (incl. atomization-mechanical-repeat with rotation rule)
   - #5 Single CTA
   - #6 Asset specs
   - **#7 Factual Claims Check** (v1.4.0 enriched : 3 NEW sub-checks)
     - #7.0 base : never-claim match → reject_immediate
     - #7.1 product grounding (PRODUCT_PROMOTION must trace ≥1 STRUCTURE/EXAMPLES claim) → soft-fail if not
     - #7.2 structural reference match (chapter/module names) → reject_immediate if no STRUCTURE claim
     - #7.3 anecdote source (specific persons/cases) → soft-fail if no EXAMPLES/attribution
   - **#8 Reader-Honesty** ratio reader-first ≥ 70% (threshold by awareness_stage)
8. If pass: split output into 2 files
   - `campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md` (PURE CONTENT, copy-paste ready, no metadata, no `{...}` placeholders)
   - `campaigns/{slug}/content/posts/.meta/{YYYY-MM-DD}-{channel}-{pillar-short}.yaml` (METADATA full audit trail)
9. Update calendar: status='concrete', `body_path`, `meta_path`, `generated_at`, `awareness_stage`, `category`. Update `STATE.yaml.atomization_history[pillar_id].append(variant_used)`.

**Resume mode** : if crash mid-P4, resume from last slot with confirmed `status='concrete'`. Skip already-concrete slots.

**If Gate #7.2 reject_immediate (structural reference unmatched)** : jeter le draft, slot stays `outline`, log `manual_review_needed: structural reference {X} not in STRUCTURE claims`. NO RETRY.

**If Gate #7 base reject_immediate (never-claim match)** : same — no retry, stays `outline`.

**If soft-fail (#7.1 grounding OR #7.3 anecdote OR generic unverified ≤2)** : retry one time with refined input (constrain to ledger). If fails again: `manual_review_needed`, continue to next slot.

**Coût estimé v1.4.0** : ~1.5-2M tokens for 90-day full-window (vs 500K for 14d v1.3.0). User accepts ("pas besoin d'économiser").

**Wall-clock estimate** : ~10-30 min for 90-270 sequential Task calls with retries.

### P5 — PACKAGING (v1.4.0 — single-run, full-window concrete)

**Action**:

1. Generate `strategy/00-product-brief.md` (2-page summary of P0+P0.5 product structure + P1+P1.5 ledger highlights).
2. Generate `strategy/01-market-research.md` (consolidated from P2).
3. All P3 artifacts already exist (P3.A through P3.E + optional P3.F Rumelt).
4. Generate `strategy/11-content-calendar-Nd-full.csv` (RENAMED v1.4.0): all slots `status='concrete'` with `body_path` + `meta_path`, OR `status='manual_review_needed'`. Columns: `date, channel, pillar, format, awareness_stage, category, body_path, meta_path, hypothesis, status, generated_at`.
5. Generate `strategy/strategy-summary.md` (2-page exec summary: diagnosis, guiding policy, coherent action, primary KPI, top 3 risks, hypotheses to validate, tradeoffs résolus, narrative-hypotheses-requiring-confirmation, manual_review_needed_count summary).
6. Generate `strategy/handoff-to-executor.yaml` v1.4.0 with sections: product, icp, offer, awareness, positioning, growth, distribution, content (full_window_concrete_count, manual_review_needed_count, posts_directory, meta_directory, channel_distribution, schema_version: v1.4.0-full-window), tripwires_top3, goals, hypotheses_to_validate, unknowns, ledger_path, never_claims_path, **product_content_path** (NEW v1.4.0), **product_content_completeness** (NEW v1.4.0), executor_handoff.
7. Run **completeness checklist** v1.4.0 (see `./references/completeness-checklist.md`): **30 points** (28 v1.3.0 + 2 NEW Section M : product-content ingestion + STRUCTURE/EXAMPLES grounding rate). If <90% pass, identify weak phase and loop back.
8. If ≥90% pass, set `STATE.yaml.status = ready-for-executor`.

**Notes v1.4.0** :
- `strategy/09-geo-plan.md` : NO LONGER GENERATED.
- `strategy/p3f-rumelt-aval.md` : opt-in only via `--rumelt-aval`.
- `strategy/10-instrumentation.md` → `strategy/10-tripwires-top3.md` (3 KPIs only).
- `strategy/11-content-calendar-14d-then-outline.csv` → `strategy/11-content-calendar-Nd-full.csv` (full window, no outline status).
- `intake/product-content.md` : NEW source-of-truth for STRUCTURE/EXAMPLES claims.

## Output Structure v1.4.0 (the deliverable)

After P5, `campaigns/{slug}/` contains:

```
campaigns/{slug}/
├── STATE.yaml
├── intake/
│   ├── url-crawl.md
│   ├── product-content.md                ← NEW v1.4.0 (source-of-truth for STRUCTURE+EXAMPLES)
│   ├── batch-1-product.md ... batch-5-voice-goals.md
│   ├── verified-claims.csv               ← v1.3.0 + STRUCTURE/EXAMPLES from product-content
│   └── never-claims.txt                  ← v1.3.0 + v1.4.0 default entries
├── research/
│   ├── competitors.md
│   ├── market-context.md
│   └── icp-personas.md
├── strategy/                              ← LIVRABLE FINAL — input for promote-executor
│   ├── 00-product-brief.md
│   ├── 01-market-research.md
│   ├── 02-jtbd-switch.md
│   ├── 03-positioning.md
│   ├── 04-offer-audit.md
│   ├── 05-growth-fits.md
│   ├── 06-distribution-philosophy.md
│   ├── 06-distribution-plan.md
│   ├── 07-content-pillars.md             ← awareness_stage tags + must_quote_from v1.4.0
│   ├── 08-channel-strategy.md
│   ├── 10-tripwires-top3.md
│   ├── 11-content-calendar-Nd-full.csv   ← RENAMED v1.4.0 (full window, no outline)
│   ├── operator-consultations/{name}.md  ← P3.C consultations + narrative_hypotheses + must_quote_from v1.4.0
│   ├── strategy-summary.md               ← exec summary
│   ├── handoff-to-executor.yaml          ← contract with promote-executor (v1.4.0 schema)
│   ├── completeness-audit.md             ← 30-point check v1.4.0
│   └── p3f-rumelt-aval.md                ← OPT-IN only (flag --rumelt-aval)
└── content/                               ← v1.3.0 schema split (unchanged)
    ├── posts/
    │   ├── 2026-MM-DD-{channel}-{pillar}.md   ← PURE CONTENT (copy-paste ready)
    │   └── .meta/
    │       └── 2026-MM-DD-{channel}-{pillar}.yaml  ← METADATA (gates audit, asset specs, etc.)
    └── batch-reports/                     ← from content-batcher runs
```

**Files NOT generated in v1.3.0 default** (compared to v1.2.0):
- `strategy/09-geo-plan.md` — CUT entirely (defer to standalone skill v1.3.1+).
- `strategy/p3g-rumelt-aval.md` — opt-in only via `--rumelt-aval` flag (renamed `p3f-rumelt-aval.md`).
- `strategy/10-instrumentation.md` (full 8-tripwires) — replaced by `10-tripwires-top3.md`.
- `strategy/11-content-calendar-90d.csv` (90 detailed) — replaced by 14d concrete + 76d minimal outline.

## Test Signature

The strategy package has succeeded if:

1. **Rumelt kernel test**: a senior strategist reads `strategy-summary.md` and can identify the diagnosis, guiding policy, and coherent action in <2 minutes without re-reading.
2. **Consultant test**: "Would a senior marketing consultant paid $5K-15K sign this dossier?" If no, identify the weak phase and re-run.
3. **Tomorrow test** (cf. `../../references/skill-grammar.md` Part 4): the user remembers, the next day, the diagnosis in one sentence and the guiding policy in one sentence.
4. **Completeness checklist**: 40 points scored ≥90% (see `./references/completeness-checklist.md`).
5. **Handoff test**: a fresh agent (or `promote-executor`) can read `handoff-to-executor.yaml` and start executing without re-reading any of the upstream markdown.

## Anti-patterns to AVOID

- **Asking questions about marketing method** (which channel, which copy framework, which cadence). The strategist DECIDES these. Ask only about THE PRODUCT.
- **Skipping P0.5 product content ingestion** (NEW v1.4.0). Without `intake/product-content.md`, claims STRUCTURE/EXAMPLES are missing → 70%+ posts fail Quality Gate #7.1 grounding. P0.5 is non-negotiable in mode guided. In autopilot, mark degraded mode explicitly.
- **Skipping P1.5 ledger validation in mode guided** (v1.3.0). Without user-validated `verified-claims.csv`, P3+P4 hallucinate factual claims. Non-negotiable in mode guided.
- **Skipping the mental Rumelt validator at P3.A start**. Without it, the synthesis lacks a diagnosis pass. (The opt-in `--rumelt-aval` flag adds a more formal aval check in P3.F.)
- **Treating "all channels" as a strategy**. The whole point of the synthesis is to **prioritize**.
- **Skipping unknowns**. Mark `hypothesis_to_validate` honestly. Don't fabricate. Use `narrative_hypotheses` (P3.C) for narrative angles requiring user confirmation.
- **Pattern #11 (explanatory extension)** in any artifact. Anti-pattern detection at P4 Quality Gate #4.
- **Re-running operator skills more than 2× per phase**. If output fails twice, escalate, don't loop infinitely.
- **Producing output for the user to read first**. The exec summary is for HUMANS. The handoff YAML is for `promote-executor`. Different artifacts, different audiences.
- **Generating `strategy/09-geo-plan.md` or `strategy/10-instrumentation.md` (full 8-tripwires)** — these are CUT. Use `strategy/10-tripwires-top3.md` instead.
- **Putting metadata into `content/posts/{slug}.md`** — content `.md` is PURE CONTENT only. All metadata goes into `.meta/{slug}.yaml`.
- **Letting an operator subagent fabricate factual claims about the author/process** OR **adjacent stories not in the product** (NEW v1.4.0). Reject any post where Quality Gate #7 fails (any sub-check).
- **Generating posts with `status='outline'` v1.4.0** — single-run produces `concrete` or `manual_review_needed`, no outline state.
- **Telling stories adjacent to the product instead of from the product** (NEW v1.4.0). PRODUCT_PROMOTION posts must trace ≥1 STRUCTURE/EXAMPLES claim. INDUSTRY_PERSPECTIVE posts (thought-leadership) are explicitly tagged in calendar.
- **Inferring chapter/module/feature names from author interviews** (NEW v1.4.0). STRUCTURE/EXAMPLES claims come EXCLUSIVELY from `intake/product-content.md`.

## Pattern Compliance (per `../../references/skill-grammar.md`)

- [x] Pattern 1 — Pipeline Position: this skill is the entry point of Part 1, runs before promote-executor.
- [x] Pattern 2 — NEVER: 6+ explicit "You NEVER" statements.
- [x] Pattern 3 — Frontmatter trigger AND non-trigger: described above.
- [x] Pattern 4 — BEFORE-MANDATORY: 3 conditions + 3 mandatory reads.
- [x] Pattern 5 — Genre-adjusted: pipeline adapts to product type (software / non-software for PLG; video / non-video for MrBeast).
- [x] Pattern 7 — Max iterations + escalation: 2 max per delegation, escalate to `manual_review_needed`.
- [x] Pattern 8 — Test signature: 5 verifiable post-package checks.
- [x] Pattern 9 — Numbered moves: 5 phases + 15 P3 delegations + 8 P4 actions, all enumerated.
- [x] Pattern 10 — YAML state file: `STATE.yaml`.
- [x] Pattern 11 — Dispatch templates: see `./references/delegation-matrix.md` for verbatim invocation strings.
- [x] Pattern 12 — Output structured: 14-file deliverable with documented schema.
- [x] Pattern 13 — `version: 0.1.0` + changelog.
- [x] Pattern 14 — Imperative second person: "You ORCHESTRATE."
- [x] Pattern 15 — Anti-patterns explicitly listed.

## Changelog

- **0.4.0** (2026-05-01) — v1.4.0 BREAKING. Source-Truth Ledger + Single-Run. NEW phase P0.5 PRODUCT CONTENT INGESTION ingests product-content.md as source-of-truth for STRUCTURE+EXAMPLES claims. Operator-consultations P3.C have new `must_quote_from` field. Quality Gate #7 enriched with 3 NEW checks (#7.1 product grounding, #7.2 structural reference match hard-fail, #7.3 anecdote source). P4 produces full configured window (default 90d, configurable `--days N`) in single-run, drops `outline` status. content-batcher SKILL DELETED (folded into strategist). Atomization library extended to 15 variants. 30-point completeness checklist (was 28). Net token budget: ~1.6-2.0M for 90d full-window single-run.
- **0.3.0** (2026-05-01) — v1.3.0 BREAKING. Phase P1.5 Claims Extraction & Validation introduced. P3 trimmed from 7 to 5 sub-phases (A-E ; ex-F GEO cut entirely, ex-G Rumelt-Aval opt-in via `--rumelt-aval`). P3.E adds Schwartz awareness routing in calendar + top-3-tripwires consolidation (replaces full 8-tripwire instrumentation). P4 receives 2 new Quality Gates (#7 factual claims check + #8 reader-honesty) and produces output as 2-file split (pure content `.md` + metadata `.meta.yaml`). P5 generates `11-content-calendar-14d-then-outline.csv` (replaces 90d detailed). 28-point completeness checklist (replaces 40-point). Net token budget: ~1.2-1.3M vs ~1.51M v1.2.0 (15-20% reduction at higher quality).
- **0.2.0** (2026-04-29) — v1.1.0/v1.2.0. Two-pass orchestration (consultation P3.C + production P4). Read+Task pattern v1.2.0 (37 internal prompts under `prompts/`).
- **0.1.0** (2026-04-28) — Initial release. Sub-school A (Kitchen-sink orchestrator). 5 phases, 15 P3 delegations, 14 deliverable files.
