# Delegation Matrix — verbatim invocation prompts for P3 (v1.3.0)

The strategist constructs the prompt by template-filling from `STATE.known_facts`, prior artifacts, AND the `verified-claims.csv` ledger (v1.3.0).

---

## v1.3.0 — Two-pass orchestration with Read+Task + ledger

**P3 has 5 sub-phases A-E** (P3.F Rumelt-Aval is OPT-IN via `--rumelt-aval` flag ; ex-P3.F GEO-Plan is CUT). See SKILL.md.

Every operator/persona/framework prompt supports two modes:

- **Mode CONSULTATION** (used in P3.C): operator gives strategic verdict. Output structured (8 fields):
  `feasibility_score`, `strategic_recommendations` (sourced), `cadence_proposed`, `content_pillar_adjustments`, `prerequisites_or_blockers`, `anti_patterns`, `recommended_skip_or_defer`, **`narrative_hypotheses` (NEW v1.3.0)**.
- **Mode PRODUCTION** (used in P4 Content Production + content-batcher): operator generates concrete content. Output structured: title + body + `factual_claims_used` + `narrative_gaps_to_fill` + assets_specs + posting_metadata + `atomization_variant_used`.

Routing per channel — see `../../../references/content-production.md` for the complete table. All prompts under `prompts/{operators,orchestrators,personas,frameworks,tactical,utility}/{name}/prompt.md` ; invoked via **Read + Task tool**.

```
INVOCATION PATTERN v1.2.0 (Read + Task) :

  1. Read prompts/{category}/{name}/prompt.md → operator_content
  2. Spawn Task(subagent_type="general-purpose", prompt=operator_content + context + mode_instruction)
  3. Subagent returns structured output (consultation or production)
  4. Strategist saves to operator-consultations/{name}.md or content/posts/...

Channel routing (excerpt — full table in references/content-production.md) :

ORGANIC :
  X/Twitter             → prompts/personas/x-mastery/prompt.md
  LinkedIn organic      → prompts/operators/welsh-linkedin/prompt.md
  YouTube long-form     → prompts/personas/mrbeast/prompt.md
  TikTok/Reels/Shorts   → prompts/operators/hormozi-shortform/prompt.md
  Newsletter (volume)   → prompts/operators/mcgarry-newsletter/prompt.md
  Substack premium      → prompts/operators/lenny-substack/prompt.md
  Founder cross-channel → prompts/personas/gerhardt-founder/prompt.md
  Podcast               → prompts/operators/ferriss-podcast/prompt.md
  Cold/Warm B2B         → prompts/operators/robinson-outbound/prompt.md
  Discord/Community     → prompts/operators/isenberg-community/prompt.md
  Instagram organic     → prompts/operators/johnson-instagram/prompt.md
  SEO/GEO               → prompts/operators/indig-geo-seo/prompt.md

PAID :
  Meta Ads              → prompts/operators/faris-meta-and-fundamentals/prompt.md
  LinkedIn Ads          → prompts/operators/wilcox-linkedin-ads/prompt.md
  Google PMax           → prompts/operators/ryan-pmax/prompt.md
  Google Search/PPC     → prompts/operators/vallaeys-google/prompt.md
  Mobile/iOS14          → prompts/operators/seufert-mobile-attribution/prompt.md
  TikTok/Snapchat Ads   → prompts/operators/sanchez-tiktok/prompt.md
  Amazon/YouTube Ads    → prompts/operators/curry-amazon-youtube/prompt.md

CHANNEL-STRATEGIST (orchestrator) :
  Channel mix proposal  → prompts/orchestrators/channel-strategist/prompt.md

FOUNDATIONS (P3.A) :
  Hormozi offer audit   → prompts/personas/hormozi/prompt.md
  Schwartz awareness    → prompts/personas/schwartz/prompt.md
  Ammar contrarian      → prompts/personas/ammar/prompt.md
  PG distribution       → prompts/personas/paul-graham/prompt.md
  Steve Jobs vision     → prompts/personas/steve-jobs/prompt.md
  Holiday earned media  → prompts/personas/holiday/prompt.md
  Cialdini levers       → prompts/frameworks/cialdini/prompt.md
  Voss negotiation      → prompts/frameworks/voss/prompt.md
  Dunford positioning   → prompts/frameworks/dunford-positioning/prompt.md
  JTBD-Switch           → prompts/frameworks/jtbd-switch/prompt.md
  Four-Fits             → prompts/frameworks/growth-four-fits/prompt.md
  PLG-Design            → prompts/frameworks/plg-design/prompt.md
  GEO-Optimization      → prompts/frameworks/geo-optimization/prompt.md
  AI-Content-Pipeline   → prompts/frameworks/ai-content-pipeline/prompt.md
  Customer research     → prompts/tactical/customer-research/prompt.md
  Pricing strategy      → prompts/tactical/pricing-strategy/prompt.md

FRAMEWORK references (8) — read directly, NO Task spawn:
  Reddit, HN+launches, Facebook, Pinterest-organic, Emerging-platforms,
  Paid-X-Reddit-Pinterest, Paid-emerging-2026, Paid-other-niches.
  → references/channel-{name}.md (read inline, generate via strategist's own LLM)
```

**Strategic-consultation Read+Task pattern v1.3.0** (reused for every operator/persona) :

```python
# Step 1: Read the operator/persona prompt
operator_path = "prompts/operators/welsh-linkedin/prompt.md"  # from routing table above
operator_content = Read(operator_path)

# Step 2: Read the verified-claims ledger + never-claims (NEW v1.3.0)
verified_claims = Read("campaigns/{slug}/intake/verified-claims.csv")
never_claims = Read("campaigns/{slug}/intake/never-claims.txt")
anti_fab_contract = Read("references/anti-fabrication-contract.md")

# Step 3: Build context payload (the 7 strategic inputs + 2 ledger inputs v1.3.0)
context = {
  "product_brief": <00-product-brief.md résumé>,
  "icp": <STATE.icp_real>,
  "jtbd": <02-jtbd-switch.md résumé>,
  "positioning": <03-positioning.md résumé + Ammar contrarian>,
  "awareness_stage": <04-offer-audit.md awareness section>,
  "goal_90d": <STATE.primary_goal>,
  "constraints": <STATE.budget_constraints>,
  "verified_claims_csv": verified_claims,  # NEW v1.3.0
  "never_claims_txt": never_claims,         # NEW v1.3.0
}

# Step 4: Spawn subagent with operator voice + ledger + context + consultation directive
Task(
  subagent_type="general-purpose",
  description=f"{operator_name} strategic consultation",
  prompt=f"""You are this operator. Adopt the voice, frameworks, signature moves, and anti-patterns described below. Speak in first person ("I"), match the cadence DNA, never paraphrase yourself in third person.

OPERATOR PROMPT (your full identity + frameworks):

---
{operator_content}
---

PROJECT-WIDE ANTI-FABRICATION CONTRACT (binding):

---
{anti_fab_contract}
---

VERIFIED CLAIMS (the only sources you can cite about product/author/process without
attribution markers or public-fact hedging) :

{verified_claims}

NEVER CLAIMS (forbidden phrasings — semantic match = REJECT_IMMEDIATE in production) :

{never_claims}

NOW RUN A STRATEGIC CONSULTATION on this campaign context:

Product : {context['product_brief']}
ICP : {context['icp']}
JTBD : {context['jtbd']}
Positioning : {context['positioning']}
Awareness stage : {context['awareness_stage']}
Goal 90d : {context['goal_90d']}
Constraints : {context['constraints']}

Return STRICTLY this Markdown structure (8 fields v1.3.0):

## feasibility_score
{{1-10}}

## strategic_recommendations
- {{3-5 actionable bullets, each citing claim_id from verified-claims.csv when factual}}

## cadence_proposed
{{concrete cadence}}

## content_pillar_adjustments
{{how to adapt pillars for this channel}}

## prerequisites_or_blockers
- {{what must exist before posting}}

## anti_patterns
- {{do-not-do for this product/audience}}

## recommended_skip_or_defer
{{if feasibility < 5: explanation. Else: 'retain'}}

## narrative_hypotheses (NEW v1.3.0)
For any narrative angle you propose that depends on a factual claim NOT in
verified-claims.csv, list it here:

- hypothesis: "{{narrative angle, e.g., 'Story arc: tried 6 months without AI then pivoted'}}"
  requires_claim: "{{the factual presupposition, e.g., 'Author had pre-AI human writing phase'}}"
  user_confirmation: REQUIRED
  fallback_if_unconfirmed: "{{safe alternative, e.g., 'Reframe as: AI from day 0 with directive cuts'}}"

If all your angles are sourced, return: `narrative_hypotheses: []`.
"""
)
```

**Save consultation output** to `campaigns/{slug}/strategy/operator-consultations/{operator-name}.md`. Critical for P4 production AND content-batcher.

**Production mode pattern**: same Read+Task structure with operator prompt + anti-fab contract + ledger, but the directive becomes "produce a concrete post for this slot" instead of "run a strategic consultation". Output schema changes to `title + body + factual_claims_used + narrative_gaps_to_fill + assets_specs + posting_metadata + atomization_variant_used`. See `../../../references/content-production.md` Quality Gates #1-#8 for what gets checked downstream.

## Conflict Resolution Matrix (when 2+ operators contradict)

| Conflict | Heuristique d'arbitrage |
|---|---|
| Welsh (LinkedIn organic) vs Gerhardt (founder cross-channel) on LinkedIn cadence | Welsh on LinkedIn-pure tactics. Gerhardt on cross-channel founder voice. Both apply (different layers). |
| McGarry (volume newsletter) vs Lenny (premium Substack) | Goal-driven: volume + paid acq → McGarry. Premium niche + paid sub → Lenny. |
| Faris (Triple Whale + Geo Lift attribution) vs Seufert (Bayesian MMM post-iOS14) | Both compatible: short-term TW+Geo (Faris), long-term MMM (Seufert). Combine. |
| Indig (stats density GEO) vs Schwartz (narrative awareness stage) on pillar structure | Combine: narrative scaffold (Schwartz) with stats embedded (Indig). |
| Hormozi-shortform (organic Reels) vs Sanchez (TikTok paid) | Organic = Hormozi-shortform. Paid = Sanchez. Different campaigns. |
| Wilcox (LinkedIn Ads $$$) vs Welsh (LinkedIn organic) | Welsh = organic content. Wilcox = paid amplification. Sister skills. |

**Generic principles** (when matrix doesn't cover):
1. Channel-specific operator > generalist on its channel.
2. Operator with documented 2024-26 results > legacy.
3. Operator operating the channel in 2026 > theoretician.

Document each arbitrage in `strategy/06-distribution-plan.md` "Tradeoffs résolus" section for transparency.

---

## P3 sub-phase dispatch summary v1.3.0

| Sub-phase | Step | Prompt path | Mode | Output artifact |
|---|---|---|---|---|
| **P3.A.1** | Mental Rumelt AMONT | `references/strategy-kernel.md` | Read | (mental check) |
| **P3.A.2** | JTBD-Switch | `prompts/frameworks/jtbd-switch/prompt.md` | Read+Task | `02-jtbd-switch.md` |
| **P3.A.3** | Category + Dunford | `references/category-design.md` + `prompts/frameworks/dunford-positioning/prompt.md` | Read+Task | `03-positioning.md` |
| **P3.A.4** | Hormozi offer audit | `prompts/personas/hormozi/prompt.md` | Read+Task | `04-offer-audit.md` |
| **P3.A.5** | Schwartz awareness | `prompts/personas/schwartz/prompt.md` | Read+Task | append to `04-offer-audit.md` |
| **P3.A.6** | Ammar contrarian | `prompts/personas/ammar/prompt.md` | Read+Task | append to `03-positioning.md` |
| **P3.A.7** | Four-Fits | `prompts/frameworks/growth-four-fits/prompt.md` | Read+Task | `05-growth-fits.md` |
| **P3.A.8** | PLG-Design (CONDITIONAL: software) | `prompts/frameworks/plg-design/prompt.md` | Read+Task | append to `05-growth-fits.md` |
| **P3.A.9** | Psychology Cialdini | `references/psychology-canon.md` | Read | (mental input) |
| **P3.A.10** | Paul Graham distribution philosophy | `prompts/personas/paul-graham/prompt.md` | Read+Task | `06-distribution-philosophy.md` |
| **P3.B.1** | Channel-strategist mix | `prompts/orchestrators/channel-strategist/prompt.md` | Read+Task | DRAFT `06-distribution-plan.md` |
| **P3.C.{n}** | Per-channel consultation | per `content-production.md` routing | Read+Task (CONSULTATION mode) | `operator-consultations/{name}.md` |
| **P3.D** | Mix refinement | `prompts/orchestrators/channel-strategist/prompt.md` | Read+Task | `06-distribution-plan.md` final |
| **P3.E.1** | Pillars + voice consolidation | strategist inline | (synthesis) | `07-content-pillars.md`, `08-channel-strategy.md` |
| **P3.E.2** | Top-3 tripwires | strategist inline | (synthesis) | `10-tripwires-top3.md` |
| **P3.F (OPT-IN)** | Rumelt AVAL | `references/strategy-kernel.md` | Read + 8-point check | `p3f-rumelt-aval.md` |

**CUT in v1.3.0** (no longer generated): ex-Step l (Geo Indig consultation + Geo plan), ex-Step n (Holiday earned-media), ex-Step m full Faris+Seufert instrumentation (replaced by top-3 tripwires inline in P3.E.2). These were ~0% consumed by P4 in v1.2.0 campaigns.

## Foundations invocation prompts (P3.A — minimal templates)

Each P3.A step uses the Read+Task pattern documented above. The prompt template per step :

```
Read+Task pattern :
  1. operator_content = Read(prompt_path)
  2. ledger = Read("intake/verified-claims.csv")
  3. never_claims = Read("intake/never-claims.txt")
  4. anti_fab = Read("references/anti-fabrication-contract.md")
  5. context = build context from STATE + prior artifacts
  6. Task(subagent_type="general-purpose", prompt=
        operator_content + anti_fab + ledger + never_claims + context + step_directive)
  7. Save subagent output to artifact_path
```

Step-specific context payload :

| Step | Context fields | Step directive |
|---|---|---|
| P3.A.2 (JTBD) | product_one_liner + icp_real + jtbd_user_words + before_after_day + switch_moment + alternatives | "Produce a structured JTBD-Switch analysis: 4 Forces, moment of struggle, 3 dimensions." |
| P3.A.3 (Dunford) | product_one_liner + hidden_critical_feature + tech_primitive + icp + user_described_category + alternatives + category_mode + category_stage | "Produce a Dunford 5+1 positioning analysis + one-sentence positioning statement." |
| P3.A.4 (Hormozi) | product_one_liner + pricing + pricing_variants + ltv + margin + cac_target + free_offering + jtbd + switch_moment | "Run a full offer audit: Value Equation, offer score, Core Four allocation." |
| P3.A.5 (Schwartz) | product_one_liner + icp + current_copy_samples + research_mentions + competitor_headlines | "Diagnose awareness stage + sophistication level + mass desire + 2-3 prescribed headlines." |
| P3.A.6 (Ammar) | positioning_one_sentence + category_mode + standard_industry_narrative | "Au fond, c'est quoi le vrai jeu ? Donne contrarian POV." |
| P3.A.7 (Four-Fits) | product_one_liner + icp + existing_channels + pricing_arpu + primary_goal + current_bottleneck | "Score 4 fits + identify bottleneck + ONE prescribed action." |
| P3.A.8 (PLG, software only) | product_type + acv_range + ttv + buyer_decision_unit + existing_gtm | "Walk decision tree + unit economics gate + recommend GTM model A-E." |
| P3.A.10 (PG distribution) | product_one_liner + category_stage + existing_channels_with_traction | "First-100-users plan + do-things-that-don't-scale guidance." |

Each step's quality gate verifies (a) artifact exists at expected path, (b) required sections present, (c) no Pattern #11 violations, (d) any factual claim cites `claim_id` from ledger or uses public-fact / attributed marker (per `anti-fabrication-contract.md`).

## P3.C Strategic-Consultation invocation prompt (universal template)

For each channel in primary + secondary mix from P3.B draft, run the consultation prompt documented above (in section "Strategic-consultation Read+Task pattern v1.3.0"). The prompt is identical across all operators ; only `operator_path` and the operator's voice change.

The 8 fields output (saved to `strategy/operator-consultations/{name}.md`):
1. `feasibility_score` (1-10)
2. `strategic_recommendations` (sourced bullets, citing claim_id where factual)
3. `cadence_proposed`
4. `content_pillar_adjustments`
5. `prerequisites_or_blockers`
6. `anti_patterns`
7. `recommended_skip_or_defer`
8. `narrative_hypotheses` (NEW v1.3.0 — proposed angles whose factual presupposes are NOT in the ledger)

## P4 Production invocation prompt (universal template)

Same Read+Task pattern but mode = PRODUCTION. The directive becomes :

```
NOW PRODUCE A POST for this slot:

Slot context:
- date: {YYYY-MM-DD}
- channel: {channel}
- pillar: {pillar from 07-content-pillars.md}
- format: {format}
- awareness_stage: {Schwartz stage from calendar}
- hypothesis: {slot.hypothesis from calendar}

Operator strategic context (from P3.C consultation):
- strategic_recommendations: {...}
- cadence_proposed: {...}
- content_pillar_adjustments: {...}
- anti_patterns: {...}
- narrative_hypotheses (status if any are confirmed by user, else fall back): {...}

Atomization variant rotation (NEW v1.3.0):
- Variants already used for this pillar: [{...list...}]
- You MUST pick a variant NOT in this list. See content-production.md for 10 available variants.

Return STRICTLY this YAML structure:

title: "..."
body: |
  ...  # NO {...} placeholders allowed for status='concrete' delivery
factual_claims_used:
  - claim_id: ...
    where_in_post: ...
  - public_fact: ...
    where_in_post: ...
  - attributed: ...
    where_in_post: ...
narrative_gaps_to_fill:
  - gap: "..."
    needed_for: "..."
    fallback_if_unconfirmed: "..."
assets_specs:
  ...
posting_metadata:
  ...
atomization_variant_used: {one of the 10 variants}
```

Output is processed through 8 Quality Gates per `../../../references/content-production.md`. If pass, split into 2 files (pure content `.md` + metadata `.meta.yaml`).

## Quality gates summary (artifact-level, P3 sub-phases)

For each step's artifact, the strategist runs a structural check:
1. **File exists** at expected path.
2. **Required sections** present (per quality gate listed above).
3. **No Pattern #11** (auto-explanatory extension — see `../../../references/skill-grammar.md` Part 5). Use a heuristic check: phrases like "which means that...", "this is because...", "what this means for you...", "in other words..." appearing >2 times = flag.
4. **No fabricated numbers** (no specific stats/percentages without source). v1.3.0 STRICT: cross-check any claim referencing the product/author/process against `verified-claims.csv`.

If a gate fails, retry the delegation ONCE with refined input. If second retry fails, mark `manual_review_needed` in STATE for that artifact, continue.

## Changelog

- **0.3.0** (2026-05-01) — v1.3.0. Added ledger context (verified-claims.csv + never-claims.txt + anti-fabrication-contract.md) to all Read+Task invocations. Added `narrative_hypotheses` (8th consultation field). Cut Steps l (Geo) + n (Holiday earned-media) + ex-Step m full instrumentation. Trimmed delegation matrix from 15 steps to ~12 + 1 channel-strategist + per-channel cascade.
- **0.2.0** (2026-04-29) — v1.1.0/v1.2.0. Two-pass orchestration (P3 sub-phases A-G). Read+Task pattern v1.2.0.
- **0.1.0** (2026-04-28) — Initial release.

