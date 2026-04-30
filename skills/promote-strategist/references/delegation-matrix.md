# Delegation Matrix — verbatim invocation prompts for P3 (v1.1.0)

The strategist constructs the prompt by template-filling from `STATE.known_facts` and prior artifacts.

---

## v1.1.0 — Two-pass orchestration with cascade

**P3 is now split in 7 sub-phases A-G** (see SKILL.md). This file covers each sub-phase below. Every operator skill supports two modes:

- **Mode CONSULTATION** (used in P3.C and P3.F): operator gives strategic verdict, NOT content production. Output structured: `feasibility_score`, `strategic_recommendations`, `cadence_proposed`, `content_pillar_adjustments`, `prerequisites_or_blockers`, `anti_patterns`, `recommended_skip_or_defer`.
- **Mode PRODUCTION** (used in P4 Content Production): operator generates concrete content (titles, bodies, assets specs).

Routing per channel — see `../../../references/content-production.md` for the complete table (channel → prompt path). Operators and personas are NOT skills anymore (v1.2.0 BREAKING) — they live under `prompts/{operators,orchestrators,personas,frameworks,tactical,utility}/{name}/prompt.md` and are invoked via **Read + Task tool**.

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

**Strategic-consultation Read+Task pattern v1.2.0** (reused for every operator/persona) :

```python
# Step 1: Read the operator/persona prompt
operator_path = "prompts/operators/welsh-linkedin/prompt.md"  # from routing table above
operator_content = Read(operator_path)

# Step 2: Build context payload (the 7 strategic inputs)
context = {
  "product_brief": <00-product-brief.md résumé>,
  "icp": <STATE.icp_real>,
  "jtbd": <02-jtbd-switch.md résumé>,
  "positioning": <03-positioning.md résumé + Ammar contrarian>,
  "awareness_stage": <04-offer-audit.md awareness section>,
  "goal_90d": <STATE.primary_goal>,
  "constraints": <STATE.budget_constraints>
}

# Step 3: Spawn subagent with operator voice + context + consultation directive
Task(
  subagent_type="general-purpose",
  description=f"{operator_name} strategic consultation",
  prompt=f"""You are this operator. Adopt the voice, frameworks, signature moves, and anti-patterns described below. Speak in first person ("I"), match the cadence DNA, never paraphrase yourself in third person.

OPERATOR PROMPT (your full identity + frameworks):

---
{operator_content}
---

NOW RUN A STRATEGIC CONSULTATION on this campaign context:

Product : {context['product_brief']}
ICP : {context['icp']}
JTBD : {context['jtbd']}
Positioning : {context['positioning']}
Awareness stage : {context['awareness_stage']}
Goal 90d : {context['goal_90d']}
Constraints : {context['constraints']}

Return STRICTLY this Markdown structure:

## feasibility_score
{{1-10}}

## strategic_recommendations
- {{3-5 actionable bullets}}

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
"""
)
```

**Save consultation output** to `campaigns/{slug}/strategy/operator-consultations/{operator-name}.md`. Sémantique inchangée vs v1.1.0 — seul le mode d'invocation change (Read+Task au lieu de cascade `/skill:name`).

**Production mode** : même pattern Read+Task, juste avec un prompt different qui demande au subagent de produire title + body + assets_specs au lieu de la consultation structurée.

**Save consultation output** to `campaigns/{slug}/strategy/operator-consultations/{operator-name}.md`. Critical for P4 production AND content-batcher.

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

## Detailed sub-phase delegations

The legacy step-a-to-step-o sequence below maps to the new sub-phases as follows:

- **P3.A Foundations** = Steps a, b, c (positioning), d (Hormozi offer), e (Schwartz), f (Ammar), g (Four-Fits), h (PLG), i (psychology read), n (PG distribution philosophy).
- **P3.B Channel Mix Initial** = NEW invocation of `promote-channel-strategist`.
- **P3.C Strategic Consultation** = NEW cascade per primary/secondary channel.
- **P3.D Mix Refinement** = `promote-channel-strategist` arbitrage.
- **P3.E Pillars consolidation** = synthesis of `content_pillar_adjustments`.
- **P3.F GEO + Instrumentation consultation** = Steps l (Indig consultation), m (Faris + Seufert consultation), n (Holiday).
- **P3.G Rumelt aval** = Step o.

Steps j and k from v1.0.0 (single x-mastery + mrbeast invocations) are SUPERSEDED by the cascade in P3.C/D.

---

## Step a — Rumelt validator (AMONT)

**Type**: Reference read.

**Action**:
- Open `../../../references/strategy-kernel.md`.
- Read the "Validateur AMONT" section.
- Mental check on the inputs gathered so far (P0 + P1 + P2):
  - Is there a clear DIAGNOSIS implicit in the inputs? (One sentence: "The central challenge this product must address is [X].")
  - If no diagnosis emerges → **flag** in `STATE.warnings = [no_clear_diagnosis_from_inputs]` and proceed; the synthesis will surface this gap.

---

## Step b — `promote-jtbd-switch`

**Inputs to inject**:
- B1 product description, JTBD answer, before/after day.
- B2 ICP description, switch interview moment, alternatives compared.

**Invocation prompt**:

```
Invoke promote-jtbd-switch with the following input:

Product : {STATE.known_facts.product_one_liner}
Current ICP : {STATE.known_facts.icp_real}
JTBD as user described : {STATE.known_facts.jtbd_user_words}
Before/after day : {batch-1-product.md content for Q1.3}
Switch moment of struggle : {batch-2-icp.md content for Q2.2}
Alternatives the buyer compares to : {STATE.known_facts.alternatives}

Produce a structured JTBD-Switch analysis: 4 Forces (push, pull, anxiety, habit), the moment of struggle, the functional/emotional/social dimensions of the job. Output Markdown only, no preamble.
```

**Output**: `campaigns/{slug}/strategy/02-jtbd-switch.md`.

**Quality gate**: artifact contains explicit 4 Forces section + moment of struggle + 3 dimensions (functional/emotional/social).

---

## Step c — Category Design + Dunford

**Sub-step c.1**: Read `../../../references/category-design.md`.
- Determine: is this a Better / Different / Different+Category-creation play?
- Determine: stage of category (cold-start / tipping / escape / mature / decline).

**Sub-step c.2**: Invoke `promote-dunford-positioning`.

**Invocation prompt**:

```
Invoke promote-dunford-positioning with the following input:

Product : {STATE.known_facts.product_one_liner}
Hidden critical feature : {batch-1-product.md Q1.4}
Technical primitive : {batch-1-product.md Q1.5}
ICP : {STATE.known_facts.icp_real}
Current category as users describe it : {STATE.known_facts.user_described_category}
Alternatives compared : {STATE.known_facts.alternatives}
Category-market mode (from category-design.md analysis) : [Better | Different | Different+Category-creation]
Category stage : [cold-start | tipping | escape | mature | decline]

Produce a Dunford 5+1 positioning analysis: competitive alternatives, unique attributes, value, who-cares-a-lot, market category, trends. End with a one-sentence positioning statement.
```

**Output**: `campaigns/{slug}/strategy/03-positioning.md` with sections:
1. Category-market mode + stage (from sub-step c.1).
2. Dunford 5+1 components.
3. One-sentence positioning statement.

**Quality gate**: 5+1 components present + one-sentence statement.

---

## Step d — `promote-hormozi`

**Inputs**: B3 pricing + LTV + margin + CAC + B1 JTBD.

**Invocation prompt**:

```
Invoke promote-hormozi with the following input:

Product : {STATE.known_facts.product_one_liner}
Current pricing : {STATE.known_facts.pricing}
Tested pricing variants : {STATE.known_facts.pricing_variants}
LTV : {STATE.known_facts.ltv}
Gross margin : {STATE.known_facts.margin}
Acceptable CAC : {STATE.known_facts.cac_target}
Free tier or trial : {STATE.known_facts.free_offering}
Job-to-be-done : {STATE.known_facts.jtbd}
Switch moment : {STATE.known_facts.switch_moment}

Run a full offer audit. Apply the Value Equation (Dream Outcome × Likelihood / Time-delay × Effort). Diagnose offer strength, recommend Core Four channel allocation. Speak in your operator voice.
```

**Output**: `campaigns/{slug}/strategy/04-offer-audit.md` with sections: Value Equation breakdown (4 dimensions scored), Offer score (0-10), Core Four recommendations.

**Quality gate**: 4 Value Equation dimensions scored + offer score + Core Four section.

---

## Step e — `promote-schwartz`

**Inputs**: ICP signals from B2 + B4 (existing content), pricing context from B3.

**Invocation prompt**:

```
Invoke promote-schwartz with the following input:

Product : {STATE.known_facts.product_one_liner}
ICP : {STATE.known_facts.icp_real}
Current copy or claims : {STATE.known_facts.current_copy_samples}
Forum/Reddit/G2 mentions if known : {research/icp-personas.md mentions section}
Existing competitor headlines : {research/competitors.md headlines column}

Diagnose: at what stage of awareness is the prospect? What level of market sophistication? What is the mass desire? Output the diagnostic + 2-3 prescribed headline forms.
```

**Output**: appended to `strategy/04-offer-audit.md` under section "## Awareness stages and copy strategy". Schema: stage diagnosed (1-5), level diagnosed (1-5), mass desire identified, prescribed headline forms.

**Quality gate**: stage + level + mass desire + 2-3 example headlines.

---

## Step f — `promote-ammar`

**Inputs**: positioning from step c, plus current_copy from B5.

**Invocation prompt**:

```
Invoke promote-ammar for a contrarian reframe.

Current positioning statement : {strategy/03-positioning.md positioning_one_sentence}
Category mode : {strategy/03-positioning.md mode}
Standard industry narrative : {research/competitors.md inferred consensus}

Au fond, c'est quoi le vrai jeu ici ? Quel est l'ennemi caché ou le faux problème que tout le monde optimise ? Donne-moi une perspective contrarian que personne dans cette catégorie n'ose dire.
```

**Output**: appended to `strategy/03-positioning.md` under section "## Contrarian POV (Ammar reframe)". Schema: standard narrative summary, contrarian reframe, 2-3 sentences exploiting the reframe in copy/marketing.

**Quality gate**: contrarian section present, NOT a paraphrase of standard narrative.

---

## Step g — `promote-growth-four-fits`

**Inputs**: all upstream + B3 economics + B2 audience trend.

**Invocation prompt**:

```
Invoke promote-growth-four-fits with the following input:

Product : {STATE.known_facts.product_one_liner}
ICP : {STATE.known_facts.icp_real}
Current channels (from B5) : {STATE.known_facts.existing_channels}
Pricing model : {STATE.known_facts.pricing} ; ARPU range : {ARPU range from pricing}
Stagnation signal : {STATE.known_facts.primary_goal} (this is what we want to grow toward) ; if user mentioned a current bottleneck, : {STATE.known_facts.current_bottleneck}

Score the four fits (Market/Product, Product/Channel, Channel/Model, Model/Market) on 1-5. Identify the bottleneck (lowest, earliest in chain). Prescribe ONE action.
```

**Output**: `campaigns/{slug}/strategy/05-growth-fits.md` with full scoring table + bottleneck identified + prescribed ONE action + what-not-to-do list.

**Quality gate**: 4 fits scored + 1 bottleneck identified + 1 prescribed action.

---

## Step h — `promote-plg-design` (CONDITIONAL: software products only)

**Skip if** product is not software (physical goods, services that aren't SaaS, content products like books/courses without software platform).

**Inputs**: B3 + B1 TTV.

**Invocation prompt**:

```
Invoke promote-plg-design with the following input:

Product type : {classified : developer-tool | consumer-saas | b2b-saas | collaboration | data-platform | marketplace | vertical-app | other}
ACV range : {STATE.known_facts.pricing range converted to annual}
Time-to-value : {STATE.known_facts.ttv}
Buyer decision unit : {single-user | single-team | multi-stakeholder, derived from B2}
Current GTM : {STATE.known_facts.existing_channels summary}

Walk the decision tree, run the unit economics gate, recommend one of the 5 GTM models. Include PLG-2.0 hybrid considerations.
```

**Output**: appended to `strategy/05-growth-fits.md` under section "## GTM model recommendation".

**Quality gate**: chosen model named (A-E) + unit economics gate result + activation triggers.

---

## Step i — Read `../../../references/psychology-canon.md`

**Type**: Reference read.

**Action**: Read the 7 Cialdini principles + Ariely biases + Kahneman fast/slow. Hold these as mental input for step j (X-Mastery channel mix). The strategist will note in `strategy/04-offer-audit.md` which 3-5 levers are most applicable.

---

## Step j — `promote-x-mastery`

**Inputs**: positioning, ICP, channels existing, voice from B5, content assets from B4.

**Invocation prompt**:

```
Invoke promote-x-mastery with the following input:

Product : {STATE.known_facts.product_one_liner}
Positioning statement : {strategy/03-positioning.md positioning_one_sentence}
Contrarian POV : {strategy/03-positioning.md contrarian_section}
ICP : {STATE.known_facts.icp_real}
Awareness stage : {strategy/04-offer-audit.md awareness_stage}
Existing channels : {STATE.known_facts.existing_channels}
Brand tone : {STATE.known_facts.brand_tone}
Existing content volume : {STATE.known_facts.existing_content_count}
Hard-no channels : {STATE.known_facts.forbidden_channels}
90-day primary goal : {STATE.known_facts.primary_goal}

Build the channel mix recommendation, the 3-5 content pillars, and the cadence per channel. Apply Cialdini levers from psychology-canon.md (top 3 levers most relevant to this audience).
```

**Output**:
- `strategy/06-distribution-plan.md` (channel mix overview).
- `strategy/07-content-pillars.md` (3-5 pillars with examples).
- `strategy/08-channel-strategy.md` (per-channel cadence and tone).

**Quality gate**: 3-5 pillars with examples + cadence per primary channel + Cialdini levers identified.

---

## Step k — `promote-mrbeast` (CONDITIONAL: video channel retained)

**Skip if** step j's channel mix doesn't include YouTube, TikTok, Reels, or short-form video.

**Invocation prompt**:

```
Invoke promote-mrbeast for visual/CTR strategy.

Product : {STATE.known_facts.product_one_liner}
Video channels retained : {strategy/08-channel-strategy.md video_channels}
Content pillars : {strategy/07-content-pillars.md pillars}

For each video channel, give: title formulas (3 examples per pillar), thumbnail concepts (3), opening hook patterns, retention curve advice.
```

**Output**: appended to `strategy/08-channel-strategy.md` under section "## Visual content strategy (video)".

**Quality gate**: title formulas + thumbnail concepts + hook patterns present.

---

## Step l — `promote-geo-optimization`

**Inputs**: domain (URL), top queries derived from B2 + B4, competitors from research.

**Invocation prompt**:

```
Invoke promote-geo-optimization with the following input:

Domain : {STATE.url}
Top 5 LLM queries to be cited for : {derived from STATE.known_facts.icp_real, jtbd, category — 5 natural-language queries}
Current LLM citation status : {if known from prior testing ; if not, mark "not yet tested, baseline test included in plan"}
Top 3 competitors cited : {research/competitors.md top 3}
Constraints (PR/listing budget) : {STATE.known_facts.budget_constraints, default "modest"}

Audit the 7 GEO levers. Identify 3 weakest. Prescribe specific actions.
```

**Output**: `strategy/09-geo-plan.md` with full audit table (7 levers scored) + 3 weakest + 3 prescribed actions + measurement plan.

**Quality gate**: 7 levers scored + 3 actions prescribed + baseline test step.

---

## Step m — Demand-gen + Attribution + `promote-paul-graham`

**Sub-step m.1**: Read `../../../references/demand-gen.md`. Determine recommended budget split (creation vs capture). Default 70/30 for B2B with ACV>$5K.

**Sub-step m.2**: Read `../../../references/attribution-canon.md`. Determine attribution stack to recommend.

**Sub-step m.3**: Invoke `promote-paul-graham` for distribution philosophy.

```
Invoke promote-paul-graham with the following input:

Product : {STATE.known_facts.product_one_liner}
Stage of category : {strategy/03-positioning.md category_stage}
Current channels working : {STATE.known_facts.existing_channels with traction signals}
First-100-users strategy needed : true
PG philosophical guidance on doing-things-that-don't-scale.
```

**Output**: `strategy/10-instrumentation.md` containing:
- Demand creation vs capture split with rationale.
- Attribution stack: what to track and how (table per channel).
- Self-reported attribution mechanism design.
- Branded search baseline + target.
- Kill-switch on attribution drift.
- PG's first-100-users plan.

**Quality gate**: split decided + attribution table + self-reported mechanism + PG section.

---

## Step n — `promote-holiday`

**Inputs**: positioning, asset (the product), niche (from B2), launch goal, existing press.

**Invocation prompt**:

```
Invoke promote-holiday with the following input:

Asset : {STATE.known_facts.product_one_liner}
Niche where it's strongest : {STATE.known_facts.icp_niche_specific}
Goal (perennial / ephemeral / both) : {derived from STATE.known_facts.primary_goal — 'leads' usually = perennial-leaning, 'awareness' = ephemeral-leaning, 'sales 90d' = ephemeral-launch}
Existing press / podcasts : {STATE.known_facts.existing_press}
Constraint : {STATE.known_facts.budget_constraints}

Produce earned-media plan: TUTC chain (4 tiers with 3-5 outlets each), first-100-fans seed strategy, Stoic guard-rails, 30-day and 12-month test signatures.
```

**Output**: appended to `strategy/06-distribution-plan.md` under section "## Earned media plan (Trading Up The Chain)".

**Quality gate**: 4-tier chain present + first-100 strategy + perennial/ephemeral verdict.

---

## Step o — Rumelt validator (AVAL)

**Type**: Reference read.

**Action**:
- Re-read `../../../references/strategy-kernel.md` "Validateur AVAL" section.
- Walk the checklist (8 points):
  - Is the diagnosis explicit in `strategy/00-product-brief.md` or `strategy/strategy-summary.md`?
  - Is the guiding policy ONE coherent direction, not three?
  - Does the guiding policy explicitly EXCLUDE options?
  - Are actions mutually reinforcing?
  - No fluff (synergy / leverage / platform / ecosystem / value-add)?
  - No goals-as-strategy?
  - Each artifact in `strategy/` follows its template?
  - Hypotheses-to-validate explicit list?
- If 1 or more fail: identify which phase produced the weak artifact, loop back to that phase ONCE.
- If 2 or more fail after the loop: escalate to user with a gap analysis.
- If all pass: continue to P4.

---

## Quality gates summary

For each step's artifact, the strategist runs a structural check:
1. **File exists** at expected path.
2. **Required sections** present (per quality gate listed above).
3. **No Pattern #11** (auto-explanatory extension — see `../../../references/skill-grammar.md` Part 5). Use a heuristic check: phrases like "which means that...", "this is because...", "what this means for you...", "in other words..." appearing >2 times = flag.
4. **No fabricated numbers** (no specific stats/percentages without source).

If a gate fails, retry the delegation ONCE with refined input. If second retry fails, mark `manual_review_needed` in STATE for that artifact, continue.
