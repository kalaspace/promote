---
name: promote-strategist
description: |
  Orchestrator for end-to-end product promotion strategy. Takes a product URL, asks the user structured questions about THE PRODUCT (never about the marketing method — that's the strategist's job to decide), validates a verified-claims ledger (P1.5), researches the market, and produces a complete strategy package ready to be executed by `promote-executor` (Part 2). v1.3.0 pipeline: P0 INTAKE → P1 PRODUCT DEEP DIVE → P1.5 CLAIMS LEDGER (NEW: extract+validate factual claims to prevent fabrication downstream) → P2 MARKET RESEARCH → P3 STRATEGY SYNTHESIS (5 sub-phases A-E, trimmed from 7: cut Geo-Plan + Rumelt-Aval to opt-in flag) → P4 CONTENT PRODUCTION 14-DAY (with Quality Gates #7 fact-check + #8 reader-honesty) → P5 PACKAGING. Outputs strategy package: 11 markdown files (no longer 09-geo-plan default) + 1 trimmed calendar + verified-claims.csv + 1 handoff YAML.
  Trigger when user says: "promote-strategist", "promote {url}", "promote this product", "build a promotion strategy", "audit and strategize my product", or types `/promote-strategist {url}`. Also trigger when user describes wanting an end-to-end promotion plan from a URL. Do NOT trigger for: single-skill tactical questions, copy-only questions, executor-side tasks like posting/scheduling (that's promote-executor in Part 2). Do NOT trigger for non-product URLs (blog posts, articles — only promotable products/services/tools/courses).
license: MIT
metadata:
  author: François Neumann (promote orchestrator)
  version: 1.3.0
---

# promote-strategist · Orchestrator (Sub-school A — Kitchen-sink)

> "The promotion strategy is not a list of channels. It is a kernel: diagnosis, guiding policy, coherent action."

## Pipeline Position

This skill is the **entry point** of the `promote` system, Part 1. It orchestrates everything in `.claude/skills/promote-*` and `references/*.md` to produce a strategy package.

- **Runs FIRST** in any campaign.
- **Runs BEFORE**: `promote-executor` (Part 2, to come) — which consumes `strategy/handoff-to-executor.yaml`.
- **Reads from**: 20 references docs + 37 internal prompts under `prompts/{operators,orchestrators,personas,frameworks,tactical,utility}/{name}/prompt.md` (invoked via Read + Task, not as Claude Code skills).
- **Writes to**: `campaigns/{campaign-id}/` (a per-campaign state directory).

## v1.3.0 — Quality + Verification + Lean (BREAKING vs v1.2.0)

Built on the v1.2.0 Read+Task pattern (37 internal prompts under `prompts/`, invoked via Read tool + Task subagent ; only 2 skills exposed). v1.3.0 introduces 5 modules of patches based on post-mortem of the v1.2.0 campaign run on François' book (`amazon-fr-dp-b0gx2zpnyq`):

- **9.A — Verified Claims Ledger + Quality Gate #7 (factual claims check)**: new phase **P1.5** extracts factual claims from intake into `intake/verified-claims.csv` + `intake/never-claims.txt`. User validates in 15 min (mode guided). All operator subagents in P3.C/P4 receive the ledger as binding constraint via the project-wide `references/anti-fabrication-contract.md`. Quality Gate #7 cross-checks each post claim before marking 'concrete'.
- **9.B — Operator prompt hardening**: 16 operator prompts include the anti-fabrication contract by reference. Welsh + Lenny + Hormozi-shortform + Curry get specific patches (hook variants library, atomization rotation rule, urgency CTA, narrative arc optional).
- **9.C — Compelling content patches**: atomization variants library (10 variants, rotation forced) ; Schwartz awareness routing in calendar (max 30% per stage) ; Quality Gate #8 reader-honesty (ratio reader-first vs author-first ≥ 70%).
- **9.D — Output schema split**: each post = 2 files. `content/posts/{slug}.md` = pure content ready to copy-paste (no metadata, no `{...}` placeholders allowed). `content/posts/.meta/{slug}.yaml` = full metadata (asset specs, posting metadata, quality gate audits, voice notes, factual_claims_used, narrative_gaps_to_fill).
- **9.E — Aggressive trim P3**: cut `09-geo-plan.md` (deferred to standalone skill) + cut `p3g-rumelt-aval.md` default (opt-in flag `--rumelt-aval`) + trim `10-instrumentation.md` to top-3-tripwires + trim `11-content-calendar-90d.csv` to `11-content-calendar-14d-then-outline.csv` (14d concrete + 76d minimal outline). Net economy: ~25% tokens P3 (~105K tokens), zero impact on post quality.

Net token budget v1.3.0 vs v1.2.0: 1.2-1.3M (vs 1.51M), **15-20% reduction at higher quality**.

See `./references/delegation-matrix.md` for the full Read+Task pattern + ledger consumption.

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

**Mandatory reads before P0**: `../../references/skill-grammar.md` (operating grammar), `../../references/strategy-kernel.md` (Rumelt validator), `../../references/anti-fabrication-contract.md` (binding factuality contract for all operator invocations), `../../references/claims-ledger-spec.md` (P1.5 ledger format), `./references/pipeline-phases.md` (this file's companion).

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

## Pipeline (6 phases v1.3.0 : P0 → P1 → P1.5 → P2 → P3 (5 sub-phases) → P4 → P5)

### P0 — INTAKE (crawl and pre-fill)

**Action**: WebFetch the URL. Extract:
- Product name (from `<title>` or hero copy).
- One-liner description (from meta description or hero subhead).
- Pricing if visible (from a `/pricing` page or hero CTA).
- Open Graph (og:title, og:description, og:image).
- Schema.org markup if present (Product, Organization, Offer).
- Top-level navigation (gives sense of feature scope).

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
```

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

### P1.5 — CLAIMS EXTRACTION & VALIDATION (NEW v1.3.0)

This phase runs immediately after P1, before P2. Its purpose: build the `verified-claims.csv` ledger that P3 + P4 will consume as binding factuality constraint. Without it, the v1.2.0 hallucination problem (~30-40% of posts contained non-sourced factual claims about the author/process) returns.

**Mandatory read**: `../../references/claims-ledger-spec.md` (format CSV + lifecycle).

**Action**:

1. Spawn the **claims-extractor subagent** (`prompts/utility/claims-extractor/prompt.md`) via Read+Task. The subagent reads `intake/batch-*.md` + `intake/url-crawl.md` and extracts every factual claim into a CSV row with `claim_id`, `claim_text`, `source_batch`, `source_quote`, `category`, `confidence`, `verified_by_user`. Do NOT fabricate claims that aren't sourced.
2. Save the extracted CSV to `campaigns/{slug}/intake/verified-claims.csv`.
3. Initialize `campaigns/{slug}/intake/never-claims.txt` with a header + empty body. The user will fill it manually if/when fabrication is detected (post-mortem) or anticipated.
4. **Gate humain (mode guided)**: present the CSV to the user with the message:
   *"Here are the {N} factual claims extracted from your intake. Review in 15 min: validate, edit, reject as needed. Add any factual claim the extractor missed. List in `never-claims.txt` any phrasing you refuse to see used about your product."*
   Wait for user response. User edits CSV directly + never-claims.txt. Then resume P2.
5. **Mode autopilot**: skip the human gate. Auto-validate `verified_by_user=TRUE` for all `confidence=HIGH` claims. Mark all `MEDIUM`/`LOW` as `verified_by_user=FALSE` (not usable as sources downstream). Leave `never-claims.txt` empty.
6. Update `STATE.yaml.claims_ledger_validated_at = <ISO date>` and `STATE.phase = P2`.

**Output**:
- `campaigns/{slug}/intake/verified-claims.csv` (~20-50 rows for a standard product).
- `campaigns/{slug}/intake/never-claims.txt`.
- `STATE.yaml` updated.

**Why this phase exists**: in v1.2.0, the strategist (P3) and operator subagents (P4) sometimes invented "narrative arc" details (e.g., "the author tried 6 months without AI before pivoting" — never said in intake). v1.3.0's claims ledger forces traceability. Quality Gate #7 in P4 will reject any post claim not in the ledger.

### P2 — MARKET RESEARCH

**Action**:

1. **WebSearch competitors** based on `category` from B2: search "{category} alternatives", "{product_one_liner} competitors", "best {product} for {ICP}". Capture top 5-10 results.
2. **WebFetch top 3 competitor sites** to compare positioning, pricing, claims.
3. **Optional**: invoke `promote-customer-research` to triangulate ICP from Reddit/G2/forum mentions if accessible.

**Output**:
- `campaigns/{slug}/research/competitors.md` (table of competitors with positioning, pricing, claims).
- `campaigns/{slug}/research/market-context.md` (category state — see `../../references/category-design.md`: cold-start / tipping / escape / mature / decline).
- `campaigns/{slug}/research/icp-personas.md` (1-3 personas with demographic + psychographic + jobs-to-be-done).

### P3 — STRATEGY SYNTHESIS (5 sub-phases A-E v1.3.0, trimmed from 7)

**This is the heart of the pipeline.** Two-pass orchestration: foundations → channel mix → operator strategic-consultation → mix refinement → consolidation. **v1.3.0 trim**: ex-P3.F (GEO Plan generation) is CUT entirely (defer to standalone skill `promote-geo-strategist` post-J+30) ; ex-P3.G (Rumelt validator AVAL) is opt-in via flag `--rumelt-aval`. Ex-P3.F's instrumentation output is now reduced to a top-3-tripwires file (in P3.E consolidation, no separate sub-phase).

The full delegation matrix is in `./references/delegation-matrix.md`. v1.2.0 + v1.3.0 invocation pattern: Read+Task on `prompts/{operators,personas,frameworks}/{name}/prompt.md` (NOT skills cascade).

**MANDATORY for all P3 sub-phase invocations**: each subagent receives `intake/verified-claims.csv` + `intake/never-claims.txt` in its context. Subagents in CONSULTATION mode must distinguish `strategic_recommendations` (sourced) from `narrative_hypotheses` (proposed angles requiring user confirmation if not in ledger) — see `../../references/anti-fabrication-contract.md`.

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

### P4 — CONTENT PRODUCTION 14-DAY (v1.3.0 with ledger + 8 quality gates + schema split)

For the **first 14 days** of the calendar (J0-J13), produce concrete posts using operator subagents in PRODUCTION mode. Each slot becomes a real post split into 2 files.

**Action** (per slot in J0-J13):

1. Read slot from calendar (date, channel, pillar, format, **awareness_stage** v1.3.0, hypothesis).
2. Read `strategy/operator-consultations/{operator}.md` for the channel's operator (from P3.C). MUST include `narrative_hypotheses` and `anti_patterns`.
3. Read `intake/verified-claims.csv` + `intake/never-claims.txt` (NEW v1.3.0 mandatory).
4. Identify operator/framework via routing table in `../../references/content-production.md`.
5. If operator/persona prompt: Read+Task in PRODUCTION mode with the **10 inputs** (positioning + pillar + cadence + voice + slot.hypothesis + strategic_recommendations + anti_patterns + narrative_hypotheses + verified_claims_csv + never_claims_txt). Subagent operates under `../../references/anti-fabrication-contract.md`.
6. If framework: read framework + apply tactiques (no subagent — strategist generates inline). Strategist STILL applies anti-fabrication contract.
7. Subagent returns: `title` + `body` + **`factual_claims_used`** + **`narrative_gaps_to_fill`** + `assets_specs` + `posting_metadata` + `atomization_variant_used`.
8. Run **8 Quality Gates** per `../../references/content-production.md` :
   - #1 Form (length + reject-on-placeholder hard)
   - #2 Word count
   - #3 Voice match
   - #4 Anti-patterns transverses (incl. atomization-mechanical-repeat)
   - #5 Single CTA
   - #6 Asset specs
   - **#7 Factual Claims Check (NEW)** — fact-checker subagent cross-checks each claim against ledger ; `reject_immediate` if never-claim match
   - **#8 Reader-Honesty (NEW)** — reader-honesty-judge subagent ratio reader-first ≥ 70%
9. If pass: split output into 2 files
   - `campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md` (PURE CONTENT, copy-paste ready, no metadata, no `{...}` placeholders)
   - `campaigns/{slug}/content/posts/.meta/{YYYY-MM-DD}-{channel}-{pillar-short}.yaml` (METADATA full audit trail)
10. Update calendar: status='concrete', `body_path`, `meta_path`, `generated_at`, `awareness_stage`.

For **J14-J89** (76 days remaining): keep status='outline' with minimal fields (date, channel, pillar, format, awareness_stage, hypothesis). They will be converted by `promote-content-batcher` on-demand at J+14, J+28, etc.

**If Quality Gate #7 reject_immediate (never-claim match)**: jeter le draft, slot reste en `outline` + `manual_review_needed: matched never-claim "{X}"`. Pas de retry.

**Coût estimé v1.3.0**: ~500K tokens (vs ~340K v1.1.0 — augmentation due aux gates #7+#8 mais compensée par les économies P3 trim).

### P5 — PACKAGING (v1.3.0 — schema split, no 09-geo, calendar 14d-then-outline)

**Action**:

1. Generate `strategy/00-product-brief.md` (2-page summary of P0+P1+P1.5 ledger highlights).
2. Generate `strategy/01-market-research.md` (consolidated from P2).
3. All P3 artifacts already exist (P3.A through P3.E + optional P3.F Rumelt).
4. Generate `strategy/11-content-calendar-14d-then-outline.csv` (NEW v1.3.0 schema): J0-J13 concrete from P4 with `body_path` + `meta_path` ; J14-J89 outline with minimal fields (`date,channel,pillar,format,awareness_stage,hypothesis,status='outline'`).
5. Generate `strategy/strategy-summary.md` (2-page exec summary: diagnosis, guiding policy, coherent action, primary KPI, top 3 risks, hypotheses to validate, tradeoffs résolus, narrative-hypotheses-requiring-confirmation).
6. Generate `strategy/handoff-to-executor.yaml` with sections: product, icp, offer, awareness, positioning, growth, distribution (channel mix + tradeoffs), content (concrete_posts_count, outlines_count, posts_directory, meta_directory, channel_distribution), tripwires_top3 (NEW from `10-tripwires-top3.md`), goals, hypotheses_to_validate, unknowns, ledger_path, never_claims_path, executor_handoff.
7. Run **completeness checklist** v1.3.0 (see `./references/completeness-checklist.md`): **28 points** (cut from 40 — removed 09-geo + full instrumentation + Rumelt-aval default checks). If <90% pass, identify weak phase and loop back.
8. If ≥90% pass, set `STATE.yaml.status = ready-for-executor`.

**Note**: `strategy/09-geo-plan.md` is NO LONGER GENERATED in v1.3.0 default. `strategy/p3f-rumelt-aval.md` only generated if flag `--rumelt-aval` was set. `strategy/10-instrumentation.md` is replaced by `strategy/10-tripwires-top3.md` (3 KPIs only).

## Output Structure v1.3.0 (the deliverable)

After P5, `campaigns/{slug}/` contains:

```
campaigns/{slug}/
├── STATE.yaml
├── intake/
│   ├── url-crawl.md
│   ├── batch-1-product.md ... batch-5-voice-goals.md
│   ├── verified-claims.csv               ← NEW v1.3.0 (ledger validated user)
│   └── never-claims.txt                  ← NEW v1.3.0
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
│   ├── 06-distribution-philosophy.md     ← NEW v1.3.0 (renamed from PG output)
│   ├── 06-distribution-plan.md
│   ├── 07-content-pillars.md             ← awareness_stage tags v1.3.0
│   ├── 08-channel-strategy.md
│   ├── 10-tripwires-top3.md              ← RENAMED from 10-instrumentation.md (trimmed)
│   ├── 11-content-calendar-14d-then-outline.csv  ← RENAMED from 11-content-calendar-90d.csv
│   ├── operator-consultations/{name}.md  ← P3.C consultations + narrative_hypotheses
│   ├── strategy-summary.md               ← exec summary
│   ├── handoff-to-executor.yaml          ← contract with promote-executor
│   ├── completeness-audit.md             ← 28-point check
│   └── p3f-rumelt-aval.md                ← OPT-IN only (flag --rumelt-aval)
└── content/                               ← v1.3.0 schema split
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
- **Skipping P1.5 ledger validation in mode guided** (NEW v1.3.0). Without user-validated `verified-claims.csv`, P3+P4 hallucinate ~30-40% factual claims about author/process. P1.5 is non-negotiable in mode guided.
- **Skipping the mental Rumelt validator at P3.A start**. Without it, the synthesis lacks a diagnosis pass. (The opt-in `--rumelt-aval` flag adds a more formal aval check in P3.F.)
- **Treating "all channels" as a strategy**. The whole point of the synthesis is to **prioritize**.
- **Skipping unknowns**. Mark `hypothesis_to_validate` honestly. Don't fabricate. Use `narrative_hypotheses` (P3.C) for narrative angles requiring user confirmation.
- **Pattern #11 (explanatory extension)** in any artifact. Anti-pattern detection at P4 Quality Gate #4.
- **Re-running operator skills more than 2× per phase**. If output fails twice, escalate, don't loop infinitely.
- **Producing output for the user to read first**. The exec summary is for HUMANS. The handoff YAML is for `promote-executor`. Different artifacts, different audiences.
- **Generating `strategy/09-geo-plan.md` or `strategy/10-instrumentation.md` (full 8-tripwires)** v1.3.0 — these are CUT. Use `strategy/10-tripwires-top3.md` instead.
- **Putting metadata into `content/posts/{slug}.md`** v1.3.0 — content `.md` is PURE CONTENT only. All metadata goes into `.meta/{slug}.yaml`.
- **Letting an operator subagent fabricate factual claims about the author/process**. Reject any post where Quality Gate #7 lists `unverified_claims` > 2 OR `reject_immediate=true`.

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

- **0.3.0** (2026-05-01) — v1.3.0 BREAKING. Phase P1.5 Claims Extraction & Validation introduced. P3 trimmed from 7 to 5 sub-phases (A-E ; ex-F GEO cut entirely, ex-G Rumelt-Aval opt-in via `--rumelt-aval`). P3.E adds Schwartz awareness routing in calendar + top-3-tripwires consolidation (replaces full 8-tripwire instrumentation). P4 receives 2 new Quality Gates (#7 factual claims check + #8 reader-honesty) and produces output as 2-file split (pure content `.md` + metadata `.meta.yaml`). P5 generates `11-content-calendar-14d-then-outline.csv` (replaces 90d detailed). 28-point completeness checklist (replaces 40-point). Net token budget: ~1.2-1.3M vs ~1.51M v1.2.0 (15-20% reduction at higher quality).
- **0.2.0** (2026-04-29) — v1.1.0/v1.2.0. Two-pass orchestration (consultation P3.C + production P4). Read+Task pattern v1.2.0 (37 internal prompts under `prompts/`).
- **0.1.0** (2026-04-28) — Initial release. Sub-school A (Kitchen-sink orchestrator). 5 phases, 15 P3 delegations, 14 deliverable files.
