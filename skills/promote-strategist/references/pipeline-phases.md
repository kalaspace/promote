# Pipeline Phases — `promote-strategist` (v1.3.0)

Detailed specification of each phase. Companion to the main SKILL.md.

**v1.3.0 changes vs v1.2.0**:
- New phase **P1.5 — Claims Extraction & Validation** between P1 and P2.
- P3 trimmed from 7 to 5 sub-phases (A-E ; ex-F GEO-Plan CUT, ex-G Rumelt-Aval opt-in via `--rumelt-aval` flag, renamed P3.F).
- P3.E adds Schwartz awareness routing in calendar + top-3-tripwires consolidation (replaces full 8-tripwire instrumentation).
- P4 adds 2 Quality Gates (#7 factual claims check + #8 reader-honesty) and produces output as 2-file split (`.md` pure content + `.meta.yaml`).
- P5 produces 11 strategy files (vs 14) — 09-geo-plan + p3g-rumelt + 10-instrumentation full removed/replaced ; calendar trimmed.

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

**Output gate**: STATE.yaml exists, url-crawl.md exists. If WebFetch fails, retry once. If still fails, mark `STATE.crawl_failed = true` and ask the user for a manual product brief paragraph.

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

## P1.5 — CLAIMS EXTRACTION & VALIDATION (NEW v1.3.0)

**Mandatory read**: `../../../references/claims-ledger-spec.md` (CSV format + lifecycle).

**Inputs**: all `intake/batch-*.md` from P1 + `intake/url-crawl.md` from P0.

**Steps**:

1. **Read+Task** the claims-extractor subagent (`prompts/utility/claims-extractor/prompt.md`):
   ```
   extractor_path = "prompts/utility/claims-extractor/prompt.md"
   extractor_content = Read(extractor_path)
   intake_files_content = concat(Read all intake/batch-*.md + url-crawl.md)
   Task(
     subagent_type="general-purpose",
     description="Claims extraction from intake",
     prompt=f"""You are the claims-extractor. Use this prompt:

   {extractor_content}

   Intake content to process:
   {intake_files_content}

   Output a CSV (verified-claims.csv format per references/claims-ledger-spec.md).
   """
   )
   ```
2. **Save the extracted CSV** to `<runtime_root>/{slug}/intake/verified-claims.csv`.
3. **Initialize never-claims.txt** with header (no body — user fills manually).
4. **Mode guided gate humain** (default):
   - Print to user: *"Voici les {N} claims extraites de ton intake. Review en 15 min : valide/rejette/édit. Liste en `never-claims.txt` les phrases que tu refuses qu'on dise sur ton produit."*
   - Wait for user response (user edits CSV directly, then says "done").
5. **Mode autopilot**:
   - Auto-validate `verified_by_user=TRUE` for all `confidence=HIGH`.
   - Mark all `MEDIUM`/`LOW` as `verified_by_user=FALSE`.
   - Leave `never-claims.txt` empty.
6. Update `STATE.claims_ledger_validated_at = <ISO>` and `STATE.phase = P2`.

**Output gate**: `verified-claims.csv` exists with ≥10 rows (a typical product yields 20-50 claims). `never-claims.txt` exists (may be empty).

**Failure modes**:
- Extractor fails (timeout, malformed CSV) → retry once. If fails again, use mode "autopilot" with user-confirmed warning.
- User refuses ledger validation in guided mode → fall back to autopilot semantics for this campaign + log warning in STATE.

**Cost**: ~5-10K tokens (1 subagent call). User time: ~15 min in guided mode.

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

**MANDATORY for ALL P3 sub-phase invocations**: each subagent receives `intake/verified-claims.csv` + `intake/never-claims.txt` in its context. Subagents in CONSULTATION mode produce 8 fields (the 7 v1.2.0 fields + new `narrative_hypotheses`). See `delegation-matrix.md` for the schema.

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

## P4 — CONTENT PRODUCTION 14-DAY (v1.3.0 with ledger + 8 quality gates + schema split)

For the **first 14 days** of the calendar (J0-J13), produce concrete posts using operator subagents in PRODUCTION mode.

**Steps**:

1. **Build calendar skeleton** : 90 days × cadence per channel. For J14-J89, status='outline' with minimal fields (`date,channel,pillar,format,awareness_stage,hypothesis,status='outline'`). For J0-J13, prepare for production.
2. **For each J0-J13 slot** (~14-42 slots depending on cadence) :
   - Read slot row (date, channel, pillar, format, **awareness_stage**, hypothesis).
   - Read `strategy/operator-consultations/{operator-name}.md` (must include `narrative_hypotheses` v1.3.0). **CRITICAL** : abort if missing.
   - Read `intake/verified-claims.csv` + `intake/never-claims.txt` (NEW v1.3.0 mandatory).
   - Identify operator/framework via routing table in `../../../references/content-production.md`.
   - If operator/persona prompt: Read+Task in PRODUCTION mode with **10 inputs** (positioning + pillar + cadence + voice + slot.hypothesis + strategic_recommendations + anti_patterns + narrative_hypotheses + verified_claims_csv + never_claims_txt). Subagent operates under `../../../references/anti-fabrication-contract.md`.
   - If framework: read framework + apply tactiques inline. Strategist STILL applies anti-fabrication contract.
   - Subagent returns: title + body + `factual_claims_used` + `narrative_gaps_to_fill` + assets_specs + posting_metadata + `atomization_variant_used`.
3. **Run 8 Quality Gates** per `../../../references/content-production.md`:
   - #1 Form (length + reject-on-placeholder hard FAIL if `{...}` in body)
   - #2 Word count
   - #3 Voice match
   - #4 Anti-patterns transverses (Pattern #11, atomization-mechanical-repeat, etc.)
   - #5 Single CTA
   - #6 Asset specs
   - **#7 Factual Claims Check (NEW)** — Read+Task `prompts/utility/fact-checker/prompt.md` ; reject_immediate if never-claim match
   - **#8 Reader-Honesty (NEW)** — Read+Task `prompts/utility/reader-honesty-judge/prompt.md` ; ratio reader-first ≥ 70%
4. **If pass**: split output into 2 files (NEW v1.3.0 schema):
   - `campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md` (PURE CONTENT, copy-paste ready, no metadata, NO `{...}` placeholders)
   - `campaigns/{slug}/content/posts/.meta/{YYYY-MM-DD}-{channel}-{pillar-short}.yaml` (METADATA: gates audit, asset specs, posting metadata, voice notes, factual_claims_used, narrative_gaps_to_fill, atomization_variant_used)
5. **If gate fails**: retry once with refined input (e.g., constrain factual_claims_used to ledger). If fails again: mark `manual_review_needed` for that slot, continue.
6. **If Gate #7 reject_immediate (never-claim match)**: jeter le draft, slot reste en `outline`, log `manual_review_needed: matched never-claim "{X}"`. Pas de retry.
7. **Output**: 14-42 concrete posts (2 files each) in `campaigns/{slug}/content/posts/` + `.meta/` subdir + calendar updates with `body_path` + `meta_path`.

**Time budget v1.3.0**: ~500K tokens for content production 14d (vs ~340K v1.1.0 — augmentation due aux gates #7+#8 mais compensée par les économies Phase 9.E).

**For J14-J89 (76 days remaining)**: NOT produced in P4. They are converted on demand by `promote-content-batcher` at user invocation (J+14, J+28, J+42, etc.). Same v1.3.0 schema split applies.

## P5 — PACKAGING (v1.3.0)

**Steps**:

1. Generate `strategy/00-product-brief.md` from intake/* artifacts (template). Highlight P1.5 ledger key claims.
2. Generate `strategy/01-market-research.md` from research/* artifacts.
3. P3 artifacts already in place (P3.A-E + optional P3.F Rumelt). Note: NO `09-geo-plan.md` in v1.3.0 default.
4. Calendar `strategy/11-content-calendar-14d-then-outline.csv` (RENAMED from 90d.csv). Columns: `date, channel, pillar, format, awareness_stage, body_path, meta_path, hypothesis, status`. J0-J13 concrete with paths filled. J14-J89 outline with minimal fields.
5. Generate `strategy/strategy-summary.md` (2-page exec summary). Must contain Rumelt's 3 elements + tradeoffs résolus from P3.D + narrative-hypotheses-requiring-confirmation.
6. Generate `strategy/handoff-to-executor.yaml` with sections including:
   - `content` (concrete_posts_count, outlines_count, posts_directory, **meta_directory**, channel_distribution)
   - `tripwires_top3` (NEW v1.3.0, from `10-tripwires-top3.md`)
   - `ledger_path: campaigns/{slug}/intake/verified-claims.csv`
   - `never_claims_path: campaigns/{slug}/intake/never-claims.txt`
7. Run `completeness-checklist.md` (28 points v1.3.0, trimmed from 40).
8. **Decision**:
   - `pass% >= 90%` → `STATE.status = ready-for-executor`.
   - `90% > pass% >= 70%` → loop back to weakest phase, retry once.
   - `pass% < 70%` → escalate.
9. Output completion summary to user with paths to `strategy-summary.md` + `content/posts/` directory + `intake/verified-claims.csv`.

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
