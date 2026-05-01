# Pipeline Phases — `promote-strategist` (v1.4.0)

Detailed specification of each phase. Companion to the main SKILL.md.

**v1.4.0 changes vs v1.3.0**:
- New phase **P0.5 — Product Content Ingestion** between P0 and P1 (subagent product-content-ingester ingests product itself as source-of-truth for STRUCTURE+EXAMPLES claims).
- P1.5 enriched : claims-extractor reads `intake/product-content.md` for STRUCTURE+EXAMPLES categories.
- P3.C operator-consultations have new `must_quote_from` field (claim_ids of STRUCTURE/EXAMPLES the pillar must ground in).
- P4 SINGLE-RUN produces full configured window (default 90 days, `--days N` flag). NO MORE `outline` status. content-batcher skill DELETED.
- P4 Quality Gate #7 enriched with 3 NEW sub-checks (#7.1 product grounding, #7.2 structural reference match, #7.3 anecdote source).
- Atomization variants library extended to 15 (was 10) for single-run on 90 days.
- P5 produces calendar `11-content-calendar-Nd-full.csv` (renamed from 14d-then-outline). 30-point completeness checklist (was 28).

## P0 — INTAKE

**Trigger**: skill is invoked with a URL.

**Inputs**:
- URL (required).
- `mode` (guided | autopilot | resume), default guided.

**Steps**:

1. **Resolve runtime root** for campaigns artifacts (apply hierarchy from main SKILL.md):
   - `$PROMOTE_HOME` if set → use this absolute path.
   - Else `./campaigns/` relative to cwd (default).
   - Else `${CLAUDE_PLUGIN_DATA}/campaigns/` if cwd not writable.
   - Record the chosen path in STATE as `runtime_root`. Fail loudly if none is writable.
2. Generate `campaign_id` (slug from URL: `domain-path`, lowercased, special-chars-stripped, capped at 40 chars).
3. Create `<runtime_root>/{campaign_id}/` if not exists. If exists and mode != resume, ask user: overwrite or new id?
4. WebFetch the URL (use the Read/WebFetch tool).
5. Parse the response for: `<title>`, `<meta name="description">`, `<meta property="og:*">`, JSON-LD schema.org, hero copy (first H1 + sub), pricing page link if visible.
6. Write `<runtime_root>/{campaign_id}/intake/url-crawl.md` with extracted facts in structured form.
7. Initialize `STATE.yaml` (see `state-schema.md` reference).
8. Set `STATE.phase = P1` (or skip to P3 if autopilot mode).

**Output gate**: STATE.yaml exists, url-crawl.md exists, **`STATE.product_type` set**. If WebFetch fails, retry once. If still fails, mark `STATE.crawl_failed = true` and ask the user for a manual product brief paragraph.

## P0.5 — PRODUCT CONTENT INGESTION (NEW v1.4.0)

**Mandatory read**: `../../../references/anti-fabrication-contract.md` Product-Promotion Constraint section.

**Inputs**: `STATE.product_type`, `intake/url-crawl.md`, URL.

**Steps**:

1. **Read+Task** the product-content-ingester subagent (`prompts/utility/product-content-ingester/prompt.md`):
   ```
   ingester_path = "prompts/utility/product-content-ingester/prompt.md"
   ingester_content = Read(ingester_path)
   url_crawl = Read("intake/url-crawl.md")
   Task(
     subagent_type="general-purpose",
     description="Product content ingestion",
     prompt=f"""You are the product-content-ingester. Use this prompt:

   {ingester_content}

   Context :
   - product_type: {STATE.product_type}
   - URL crawled: {STATE.url}
   - intake/url-crawl.md content:

   {url_crawl}

   Output the structured `intake/product-content.md` based on type-specific ingestion strategy. Return YAML report.
   """
   )
   ```
2. The subagent dispatches based on product_type :
   - `book` → Amazon Look Inside / publisher page / ASK USER for TOC + summaries
   - `saas` → multi-WebFetch on docs/features/pricing/changelog
   - `course` → course landing crawl / ASK USER for syllabus
   - `service` → ASK USER directly
   - `hybrid` → ASK USER for product structure
3. **Save** subagent's structured markdown to `<runtime_root>/{slug}/intake/product-content.md`.
4. **Mode guided** : if subagent's autopilot crawl is incomplete, the strategist relays the user-prompt the subagent constructs and waits for paste.
5. **Mode autopilot** : if crawl insufficient and no user available, save partial content + flag `STATE.product_content_completeness = "PARTIAL"` (or `MISSING` if user refused).
6. Update `STATE.yaml`:
   ```yaml
   product_content_path: intake/product-content.md
   product_content_completeness: COMPLETE | PARTIAL | MISSING
   product_content_ingested_at: <ISO date>
   phase: P0.5-completed → P1
   ```

**Output gate** : `intake/product-content.md` exists. If `MISSING`, warn user that ~70% of posts will need manual review (Quality Gate #7.1 will fail without STRUCTURE/EXAMPLES claims).

**Failure modes** :
- All crawl attempts fail + user refuses to paste → degraded mode `MISSING`.
- Subagent extracts but content is sparse (< 5 STRUCTURE entries) → flag `PARTIAL`.

**Cost** : ~10-30K tokens (subagent + multi-fetch for SaaS) + 5-15 min user time if paste needed.

## P1 — PRODUCT DEEP DIVE

**Skipped in autopilot mode** (mark all answers `ASSUMED:` in batch files, with hypotheses generated from P0 and `../../../references/skill-grammar.md` warnings noted).

**5 batches** (full text in `intake-questions.md`):

For each batch B1...B5:
1. Build a working list of questions for the batch.
2. **Skip** any question whose answer is already in `STATE.known_facts`.
3. **Skip** any question whose answer is logically derivable (e.g., if user gave name in B1, don't ask again in B2).
4. Pose remaining questions to user, ONE BATCH AT A TIME (don't dump all 30 at once).
5. Wait for user response.
6. Save responses to `intake/batch-{N}-{theme}.md`.
7. Update `STATE.known_facts`.
8. Move to next batch.

**Acceptance criteria for advancing past a batch**:
- All questions either answered, skipped (logical), or marked `unknown` (user said so).
- No empty answers.

**Loop control**: if user gives meta-questions ("why are you asking?"), answer briefly using the rationale from `intake-questions.md` for that question, then re-pose. Do not abandon a batch.

## P1.5 — CLAIMS EXTRACTION & VALIDATION (v1.4.0 with STRUCTURE+EXAMPLES)

**Mandatory read**: `../../../references/claims-ledger-spec.md` (CSV format + lifecycle, v1.4.0 schema with STRUCTURE+EXAMPLES categories + `source` column).

**Inputs**: `intake/batch-*.md` from P1 + `intake/url-crawl.md` from P0 + **`intake/product-content.md` from P0.5** (NEW v1.4.0).

**Steps**:

1. **Read+Task** the claims-extractor subagent (`prompts/utility/claims-extractor/prompt.md`):
   ```
   extractor_path = "prompts/utility/claims-extractor/prompt.md"
   extractor_content = Read(extractor_path)
   intake_files_content = concat(
     Read all intake/batch-*.md +
     Read intake/url-crawl.md +
     Read intake/product-content.md  # NEW v1.4.0
   )
   Task(...)
   ```
2. **Save** the extracted CSV to `<runtime_root>/{slug}/intake/verified-claims.csv`. v1.4.0 schema : column `source` (renamed from `source_batch`) accepts `product-content` value. Categories include STRUCTURE+EXAMPLES (sourced EXCLUSIVELY from product-content.md).
3. **Initialize never-claims.txt** with v1.4.0 default entries (any chapter title not in product-content.md, etc.).
4. **Mode guided gate humain** (default):
   - Print to user: *"Voici les {N} claims extraites (v1.4.0 typiquement 40-80, vs 20-50 v1.3.0 — augmenté par STRUCTURE+EXAMPLES from product-content.md). Review en ~20 min : valide/rejette/édite. Vérifie particulièrement les claims STRUCTURE/EXAMPLES qui sourcent les references chapter/module dans tes posts."*
   - Wait for user response.
5. **Mode autopilot**:
   - Auto-validate `verified_by_user=TRUE` for `confidence=HIGH` (incl. STRUCTURE/EXAMPLES from product-content.md if COMPLETE).
   - Mark MEDIUM/LOW as FALSE.
   - Default never-claims.txt entries left in place.
6. Update `STATE.yaml`:
   ```yaml
   claims_ledger_validated_at: <ISO>
   ledger_total_claims: N
   ledger_structure_examples_count: K  # NEW v1.4.0
   phase: P1.5-completed → P2
   ```

**Output gate**: `verified-claims.csv` exists with ≥30 rows for a product with COMPLETE product-content.md (else flag intake quality issue). If product-content.md was MISSING, ledger may have ≥10 rows but K=0 → downstream Quality Gate #7.1 will fail most PRODUCT_PROMOTION posts.

**Failure modes**:
- Extractor fails → retry once.
- product-content.md MISSING → claims-extractor produces ledger without STRUCTURE/EXAMPLES + warning notes column.
- User refuses ledger validation in guided mode → fall back to autopilot semantics + log warning.

**Cost**: ~8-15K tokens v1.4.0 (vs 5-10K v1.3.0 — increased by product-content.md ingestion). User time: ~20 min in guided mode.

## P2 — MARKET RESEARCH

**Inputs**: P0 + P1 outputs, especially:
- Product name and one-liner (B1).
- Category (B2).
- ICP (B2).
- Alternatives the buyer compares to (B2).

**Steps**:

1. **WebSearch** with 3-5 queries derived from the inputs:
   - `"{category} alternatives"` (or top tools for X)
   - `"{product_one_liner} competitors"`
   - `"best {product_type} for {ICP_short}"`
   - `"{product_name} vs"` (if product is known)
2. From results, identify top 5-10 competitors. Filter dupes.
3. **WebFetch** top 3 competitor pages — pricing page if direct comparison, else home page.
4. Build `research/competitors.md` as a table with: name, one-liner, pricing, target ICP (their stated), unique claim.
5. Determine **market context** (cf. `../../../references/category-design.md`): cold-start / tipping / escape / mature / decline. Document evidence (number of established players, depth of category language in press, search volume trends if known).
6. Write `research/market-context.md`.
7. **Optionally** (if Customer-Research skill helps): invoke `promote-customer-research` for ICP triangulation from Reddit/G2/forums.
8. Write `research/icp-personas.md` with 1-3 personas: demographic + psychographic + jobs-to-be-done.

**Time budget**: 5-10 WebSearch + WebFetch calls maximum. If research exceeds budget without convergence, stop and proceed with what's available, marking gaps as `hypothesis_to_validate`.

## P3 — STRATEGY SYNTHESIS (5 sub-phases A-E v1.3.0, ex-F+G removed/opt-in)

**This is the heart of the pipeline.** Two-pass orchestration via Read+Task on `prompts/{operators,personas,frameworks}/*/prompt.md`. See `delegation-matrix.md` for the verbatim Read+Task pattern.

**v1.3.0 trimming rationale**: post-mortem of v1.2.0 campaign (`amazon-fr-dp-b0gx2zpnyq`) showed `09-geo-plan.md` + full `10-instrumentation.md` + `p3g-rumelt-aval.md` had ~0% downstream impact on P4 content production. They are removed (Geo) or opt-in (Rumelt-Aval) or trimmed (instrumentation → top-3 tripwires).

**MANDATORY for ALL P3 sub-phase invocations** (v1.4.0): each subagent receives `intake/verified-claims.csv` + `intake/never-claims.txt` + **`intake/product-content.md`** (NEW v1.4.0) in its context. Subagents in CONSULTATION mode produce 9 fields (the 8 v1.3.0 + new **`must_quote_from`** v1.4.0 listing claim_ids of category STRUCTURE/EXAMPLES the pillar must be grounded in). For PRODUCT_PROMOTION pillars, `must_quote_from` MUST be non-empty — sinon le pillar est REJETÉ. Voir `delegation-matrix.md` pour le schema complet.

### P3.A — Foundations (no channel-specific operators)

Sequenced steps:

| Step | Path | Type |
|---|---|---|
| A.1 | `../../../references/strategy-kernel.md` | Read (mental validator AMONT) |
| A.2 | `prompts/frameworks/jtbd-switch/prompt.md` | Read+Task → `02-jtbd-switch.md` |
| A.3 | `../../../references/category-design.md` THEN `prompts/frameworks/dunford-positioning/prompt.md` | Read+Task → `03-positioning.md` |
| A.4 | `prompts/personas/hormozi/prompt.md` | Read+Task (offer audit) → `04-offer-audit.md` |
| A.5 | `prompts/personas/schwartz/prompt.md` | Read+Task (awareness stages) → append to `04-offer-audit.md` |
| A.6 | `prompts/personas/ammar/prompt.md` | Read+Task (contrarian reframe) → append to `03-positioning.md` |
| A.7 | `prompts/frameworks/growth-four-fits/prompt.md` | Read+Task → `05-growth-fits.md` |
| A.8 | `prompts/frameworks/plg-design/prompt.md` (CONDITIONAL: software only) | Read+Task → append to `05-growth-fits.md` |
| A.9 | `../../../references/psychology-canon.md` | Read (Cialdini levers, mental input) |
| A.10 | `prompts/personas/paul-graham/prompt.md` | Read+Task (distribution philosophy) → `06-distribution-philosophy.md` |

### P3.B — Channel Mix Initial Proposal

| Step | Path | Type |
|---|---|---|
| B.1 | `prompts/orchestrators/channel-strategist/prompt.md` | Read+Task → DRAFT `06-distribution-plan.md` |

### P3.C — Strategic Consultation (operators-as-strategists)

For EACH channel in primary + secondary mix (from B.1 draft), Read+Task the corresponding operator/persona prompt. Routing per `../../../references/content-production.md`. See `delegation-matrix.md` for the consultation prompt template.

Each operator returns 8 fields including `narrative_hypotheses` (NEW v1.3.0).

Save to `strategy/operator-consultations/{operator-name}.md`.

### P3.D — Mix Refinement & Conflict Resolution

`channel-strategist` aggregates the consultations:
- `feasibility_score` < 5 → defer.
- Inter-operator conflicts resolved via matrix in `delegation-matrix.md`.
- All `narrative_hypotheses` from consultations flagged for user confirmation in `strategy/06-distribution-plan.md`.
- Tradeoffs documented in same file.

### P3.E — Pillars + Cadence + Voice + Top-3 Tripwires Consolidation

Outputs:
- `strategy/07-content-pillars.md` (3-5 pillars, awareness_stage tag mandatory per pillar — Schwartz routing v1.3.0).
- `strategy/08-channel-strategy.md` (cadence + voice + format per channel).
- `strategy/10-tripwires-top3.md` (3 KPIs only — replaces full 8-tripwires v1.2.0).

**Schwartz distribution rule**: max 30% of posts per awareness_stage on the 14d concrete window. If draft calendar has 70% product-aware, force regeneration with diversification.

### P3.F (OPT-IN ONLY) — Rumelt validator AVAL via flag `--rumelt-aval`

**Default v1.3.0**: skipped. Mental Rumelt validator at A.1 + test signature at end of P5 = sufficient for most campaigns.

**If flag `--rumelt-aval` set in invocation**:
- Re-read `../../../references/strategy-kernel.md` "Validateur AVAL" section.
- Walk the 8-point checklist: diagnosis explicit, policy ONE direction (not three), policy excludes options, actions mutually reinforcing, no fluff, no goals-as-strategy, hypotheses-to-validate listed, each artifact follows template.
- Save to `strategy/p3f-rumelt-aval.md`.
- If 1+ fail: identify weakest sub-phase, loop back ONCE. If 2+ fail after loop: escalate to user.

### Cut in v1.3.0

**Cut entirely (no longer generated)**:
- `strategy/09-geo-plan.md` — Indig consultation + Holiday earned-media + GEO 7-lever audit. Defer to standalone skill `promote-geo-strategist` (v1.3.1+) post-J+30.

**Quality gate per artifact**:
1. File exists at expected path.
2. Required sections present (per quality gate listed in `delegation-matrix.md`).
3. No Pattern #11 (auto-explanatory extension — see `../../../references/skill-grammar.md` Part 5).
4. No fabricated numbers (no specific stats/percentages without source ; verify against `verified-claims.csv`).

If gate fails, retry the delegation ONCE with refined input. If second retry fails, mark `manual_review_needed` in STATE for that artifact, continue.

**Caching rule**: each artifact generated once. If `STATE.phase == P3-resume`, only re-run delegations where input artifacts changed.

**Time budget v1.3.0**: ~280K tokens for P3 (vs ~348K v1.2.0, -20% via trimming).


## P4 — CONTENT PRODUCTION FULL-WINDOW (v1.4.0 single-run, replaces 14-day v1.3.0)

v1.4.0 BREAKING : produces the **full configured window** (default 90 days, configurable via `--days N` flag) in ONE RUN. NO MORE `status='outline'`. content-batcher SKILL DELETED.

**Steps**:

1. **Build calendar skeleton** : N days (default 90) × cadence per channel = ~90-270 slots. ALL slots prepared for production. Initialize `STATE.yaml.atomization_history = {pillar_id: [] for each pillar}`.
2. **For each slot, sequentially** :
   - Read slot row (date, channel, pillar, format, **awareness_stage**, **category** (PRODUCT_PROMOTION | INDUSTRY_PERSPECTIVE) v1.4.0, hypothesis).
   - Read `strategy/operator-consultations/{operator-name}.md` (must include `must_quote_from` v1.4.0 + `narrative_hypotheses` + `anti_patterns`). **CRITICAL** : abort if missing.
   - Read inputs : `intake/verified-claims.csv` + `intake/never-claims.txt` + **`intake/product-content.md`** (NEW v1.4.0) + `STATE.yaml.atomization_history[pillar_id]`.
   - Identify operator/framework via routing table in `../../../references/content-production.md`.
   - If operator/persona prompt: Read+Task in PRODUCTION mode with **12 inputs** (10 v1.3.0 + product-content + must_quote_from + atomization_history). Subagent operates under `../../../references/anti-fabrication-contract.md` Anti-Fabrication + Product-Promotion Constraint.
   - Subagent returns: title + body + `factual_claims_used` (with category) + `narrative_gaps_to_fill` + assets_specs + posting_metadata + `atomization_variant_used`.
3. **Run 8 Quality Gates** per `../../../references/content-production.md`:
   - #1 Form (length + reject-on-placeholder hard FAIL)
   - #2 Word count
   - #3 Voice match
   - #4 Anti-patterns transverses (incl. atomization-mechanical-repeat with rotation rule v1.4.0 — 15 variants)
   - #5 Single CTA
   - #6 Asset specs
   - **#7 Factual Claims Check** (v1.4.0 enriched with 3 NEW sub-checks)
     - #7.0 base : never-claim match → reject_immediate
     - **#7.1 product grounding (NEW v1.4.0)** : if `category=PRODUCT_PROMOTION`, ≥1 STRUCTURE/EXAMPLES claim required → soft-fail if not
     - **#7.2 structural reference match (NEW v1.4.0)** : chapter/module/feature names hard-fail without STRUCTURE claim → reject_immediate
     - **#7.3 anecdote source (NEW v1.4.0)** : specific persons/cases need EXAMPLES claim or attribution → soft-fail if not
   - **#8 Reader-Honesty** ratio reader-first ≥ 70% (threshold by awareness_stage)
4. **If pass**: split output into 2 files (v1.3.0 schema, unchanged):
   - `content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md` (PURE CONTENT, copy-paste ready, NO `{...}` placeholders)
   - `content/posts/.meta/{YYYY-MM-DD}-{channel}-{pillar-short}.yaml` (METADATA full audit trail)
5. **Update STATE** : append `atomization_variant_used` to `STATE.yaml.atomization_history[pillar_id]`.
6. **If reject_immediate** (Gate #7.0 OR Gate #7.2): jeter le draft, slot stays `manual_review_needed`. NO RETRY.
7. **If soft-fail** (#7.1 grounding OR #7.3 anecdote OR generic unverified ≤2): retry once with refined constraint. If fails again: `manual_review_needed`, continue.
8. **Output**: ~90-270 concrete posts (2 files each) in `content/posts/` + `.meta/` + calendar updates.

**Resume mode** : if crash mid-P4, scan calendar for slots with `status='concrete'`, resume from first non-concrete.

**Time budget v1.4.0**: ~1.5-2M tokens for 90-day full-window. User accepts.

**Wall-clock estimate**: ~10-30 min for ~90-270 sequential Task calls.

## P5 — PACKAGING (v1.4.0)

**Steps**:

1. Generate `strategy/00-product-brief.md` from intake/* artifacts. Highlight P0.5 product structure + P1.5 ledger key claims.
2. Generate `strategy/01-market-research.md` from research/* artifacts.
3. P3 artifacts already in place (P3.A-E + optional P3.F Rumelt). Note: NO `09-geo-plan.md` in v1.4.0.
4. Calendar `strategy/11-content-calendar-Nd-full.csv` (RENAMED v1.4.0 from 14d-then-outline). Columns: `date, channel, pillar, format, awareness_stage, category, body_path, meta_path, hypothesis, status, generated_at`. ALL slots `status='concrete'` or `status='manual_review_needed'`. NO outline.
5. Generate `strategy/strategy-summary.md` (2-page exec summary). Must contain Rumelt's 3 elements + tradeoffs résolus + narrative-hypotheses-requiring-confirmation + manual_review_needed_count summary.
6. Generate `strategy/handoff-to-executor.yaml` with sections including:
   - `content` (full_window_concrete_count, manual_review_needed_count, posts_directory, meta_directory, channel_distribution, schema_version: v1.4.0-full-window)
   - `tripwires_top3` (from `10-tripwires-top3.md`)
   - `ledger_path: campaigns/{slug}/intake/verified-claims.csv`
   - `never_claims_path: campaigns/{slug}/intake/never-claims.txt`
   - **`product_content_path: campaigns/{slug}/intake/product-content.md`** (NEW v1.4.0)
   - **`product_content_completeness: COMPLETE | PARTIAL | MISSING`** (NEW v1.4.0)
7. Run `completeness-checklist.md` (30 points v1.4.0, +2 vs 28 v1.3.0 — Section M product-content + grounding).
8. **Decision**:
   - `pass% >= 90%` → `STATE.status = ready-for-executor`.
   - `90% > pass% >= 70%` → loop back to weakest phase, retry once.
   - `pass% < 70%` → escalate.
9. Output completion summary to user with paths to `strategy-summary.md` + `content/posts/` directory + `intake/verified-claims.csv` + `intake/product-content.md`.

## Resume mode

If skill is invoked with `mode = resume`:
1. Read existing `STATE.yaml`.
2. Output current phase and artifact status.
3. Identify the **first unfinished step** in the pipeline.
4. Resume from there.

## Failure modes and recovery

| Failure | Recovery |
|---|---|
| WebFetch fails on URL | Retry once. Then ask user for paragraph. Mark `crawl_failed`. |
| User skips multiple questions in P1 | Mark `hypothesis_to_validate` for each, proceed. |
| WebSearch returns nothing | Continue P2 with whatever P1 gave us. Mark `competitor_research_thin` in STATE. |
| Operator skill output fails quality gate twice | Mark `manual_review_needed` for that artifact. Continue P3. |
| P4 completeness < 70% | Loop back to weakest phase, retry once. If second loop also fails, escalate. |
| User invokes `--resume` on completed campaign | Output: "Already complete. Re-run with new ID for new campaign." |
