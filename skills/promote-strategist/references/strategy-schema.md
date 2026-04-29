# Strategy Package Schema

Structured specification of the deliverable produced in P5 (formerly P4 in v1.0.0). Every artifact in `campaigns/{slug}/strategy/` follows this schema.

The schema is the **contract** between `promote-strategist` (Part 1) and `promote-executor` (Part 2). Changes here require coordination with the executor's reading logic.

---

## v1.1.0 — Schema additions (NEW)

### `strategy/operator-consultations/` (NEW folder)

Per-operator strategic consultation files produced in P3.C. Format:

```markdown
# Strategic Consultation — {operator-name} for {campaign-id}

**Channel covered** : {channel-name}
**Generated** : {ISO date}
**Mode** : strategic-consultation (NOT production)

## feasibility_score
{1-10}

## strategic_recommendations
- {3-5 bullets ajustements clés}

## cadence_proposed
{concrete cadence : "5x/sem long-form + 1 carrousel/sem"}

## content_pillar_adjustments
{how to adapt the strategist's pillars for this channel}

## prerequisites_or_blockers
- {prerequisite 1}
- {prerequisite 2}

## anti_patterns
- {anti-pattern 1}
- {anti-pattern 2}

## recommended_skip_or_defer
{if feasibility < 5: explanation. Else: "retain"}
```

These files are CRITICAL — consumed by P4 Content Production AND by `promote-content-batcher` later for outline → concrete conversion. Without them, content generation falls back to generic LLM voice.

### File 06 — `06-distribution-plan.md` (UPDATED v1.1.0)

Now includes "Channels considered but DEFERRED" section + "Tradeoffs résolus" section. See updated schema below in File 06 details.

### File 11 — `11-content-calendar-90d.csv` (UPDATED v1.1.0)

**Old schema (v1.0.0)** : `date,channel,pillar,format,hypothesis,status`
**New schema (v1.1.0)** : `date,channel,pillar,format,title,body_outline,body_path,assets_path,status`

**Status values v1.1.0** : `outline` (default for J14-J89) | `concrete` (J0-J13 from P4, or batched from content-batcher) | `posted` (set by executor) | `archived`.

### File 12 — `strategy-summary.md` (UPDATED v1.1.0)

Now includes "Tradeoffs résolus" section (inter-operator conflicts + resolution).

### File 13 — `handoff-to-executor.yaml` (UPDATED v1.1.0)

New sections : `content` (concrete_posts_count, outlines_count, posts_directory), `channel_distribution` (primary/secondary/deferred/excluded with operator routing), `operator_consultations` (consultation paths + conflicts resolved).

### `content/posts/` (NEW folder)

Concrete posts produced in P4 + batched. Format per post: see `templates/post.md.template`. Filename: `{YYYY-MM-DD}-{channel}-{pillar-short}.md`.

### `content/batch-reports/` (NEW folder)

Reports from `promote-content-batcher` invocations. Format: `{YYYY-MM-DD-batch-report.md}` per batch.

---

## File 00 — `00-product-brief.md`

**Purpose**: 2-page summary of P0 + P1 outputs. Human-readable.

**Required sections**:

```markdown
# Product Brief — {product_name}

## One-liner
{one sentence}

## Job-to-be-done
{2-3 sentences from Q1.2}

## Day before / Day after
{from Q1.3}

## Hidden critical feature
{from Q1.4}

## Technical primitive
{from Q1.5}

## Known limitations (claims to avoid)
- {from Q1.6}

## Time-to-value
{from Q1.7}

## Origin story (if applicable)
{from Q1.8}
```

---

## File 01 — `01-market-research.md`

**Purpose**: consolidated market research from P2.

**Required sections**:

```markdown
# Market Research — {product_name}

## Category state
- **Mode**: {Better | Different | Different+Category-creation}
- **Stage**: {cold-start | tipping | escape | mature | decline}
- **Evidence**: {2-3 lines}

## Top competitors

| # | Name | One-liner | Pricing | Target ICP | Unique claim |
|---|---|---|---|---|---|
| 1 | ... | ... | ... | ... | ... |
| 2 | ... | ... | ... | ... | ... |
| 3 | ... | ... | ... | ... | ... |

## ICP personas (1-3)

### Persona 1
- **Demographic**: ...
- **Psychographic**: ...
- **JTBD**: ...
- **Channels they live in**: ...

### Persona 2
[idem]

## Audience trend
- {growing | flat | shrinking}
- Evidence: {1-2 lines}
```

---

## File 02 — `02-jtbd-switch.md`

**Purpose**: JTBD analysis from `promote-jtbd-switch`.

**Required sections**:

```markdown
# JTBD-Switch Analysis

## The Job
{the progress the customer is trying to make in their context}

## Three Dimensions
- **Functional**: ...
- **Emotional**: ...
- **Social**: ...

## 4 Forces of Progress

### Push (current pain)
{...}

### Pull (attraction of new solution)
{...}

### Anxiety (fears about switching)
{...}

### Habit (inertia of current solution)
{...}

## Moment of struggle
{the specific situation that triggers the buying decision}

## Implications for messaging
{2-3 bullet points}
```

---

## File 03 — `03-positioning.md`

**Purpose**: positioning from `promote-dunford-positioning` + Ammar contrarian.

**Required sections**:

```markdown
# Positioning

## Category-market mode
- **Mode**: {Better | Different | Different+Category-creation}
- **Stage of category**: {cold-start | tipping | ...}
- **POV (if category-creation mode)**: {3-line POV per Play Bigger}

## Dunford 5+1 components

### 1. Competitive alternatives
{what the customer would do or use without us}

### 2. Unique attributes
{what we have that the alternatives don't}

### 3. Value
{what those unique attributes do for the customer}

### 4. Best-fit customers (who cares a lot)
{the segment for whom the value matters most}

### 5. Market category
{the category context that makes our value obvious}

### +1. Trends (optional)
{trends that make this positioning timely}

## One-sentence positioning statement
{...}

## Contrarian POV (Ammar reframe)
- **Standard industry narrative**: {...}
- **Contrarian reframe — au fond c'est quoi le vrai jeu ?**: {...}
- **How to use it in copy**: {2-3 sentences}
```

---

## File 04 — `04-offer-audit.md`

**Purpose**: offer audit from `promote-hormozi` + awareness stages from `promote-schwartz`.

**Required sections**:

```markdown
# Offer Audit

## Value Equation (Hormozi)

| Dimension | Score 1-10 | Notes |
|---|---|---|
| Dream Outcome | X | ... |
| Perceived Likelihood | X | ... |
| Time Delay (lower is better) | X | ... |
| Effort & Sacrifice (lower is better) | X | ... |

**Offer score**: {composite, 0-10}
**Verdict**: {Grand Slam | Strong | Average | Weak | Commodity}

## Core Four channel allocation (Hormozi)

- **Warm outreach**: {priority, action}
- **Paid ads**: {priority, action}
- **Cold outreach**: {priority, action}
- **Content**: {priority, action}

## Awareness stages and copy strategy (Schwartz)

- **Diagnosed stage of audience**: {1-5: Most Aware | Product Aware | Solution Aware | Problem Aware | Unaware}
- **Diagnosed sophistication level of market**: {1-5}
- **Mass desire**: {one sentence}
- **Prescribed headline forms (3 examples)**:
  1. *...*
  2. *...*
  3. *...*

## Cialdini levers analysis (top 3 most relevant)

- **Lever 1**: {name + how to apply}
- **Lever 2**: ...
- **Lever 3**: ...
```

---

## File 05 — `05-growth-fits.md`

**Purpose**: growth diagnosis from `promote-growth-four-fits` + GTM model from `promote-plg-design` (if software).

**Required sections**:

```markdown
# Growth Fits Diagnostic

## Four Fits scoring

| Fit | Score 1-5 | Evidence |
|---|---|---|
| Market/Product | X | ... |
| Product/Channel | X | ... |
| Channel/Model | X | ... |
| Model/Market | X | ... |

## Bottleneck identified
{name of fit + reason it's the bottleneck}

## Prescribed ONE action
{single concrete action}

## What NOT to do until bottleneck is fixed
- {tactic A}
- {tactic B}
- {tactic C}

## GTM model recommendation (PLG, only if software)

- **Chosen model**: {A-E: Free Trial | Freemium | OSS | Reverse Trial | Sales-Assist Hybrid}
- **Rationale**: {decision tree walk-through summary}
- **Unit economics gate**: {LTV/CAC, payback, PASS/FAIL}
- **PLG-2.0 hybrid triggers** (if applicable): {...}
- **Migration plan from current GTM**: {...}
```

---

## File 06 — `06-distribution-plan.md`

**Purpose**: channel mix overview + earned media plan.

**Required sections**:

```markdown
# Distribution Plan

## Channel mix overview

### Primary channels (rank-ordered)
1. {channel} — rationale: ...
2. {channel} — rationale: ...
3. {channel} — rationale: ...

### Secondary channels (test/maintain)
- ...

### Excluded channels
- {channel}: {reason: hard-no from user, model misfit, etc.}

## Demand creation vs demand capture split
- **Recommended**: {70/30 | 80/20 | 50/50 | other} — rationale: ...
- **Demand creation channels**: {list}
- **Demand capture channels**: {list}

## Earned media plan (Trading Up The Chain — Holiday)

### Verdict
- **Perennial vs ephemeral**: {one or both}
- **Justification**: ...

### TUTC chain

| Tier | Outlets (3-5) | Angle | Status target |
|---|---|---|---|
| 1 | ... | ... | covered |
| 2 | ... | ... | covered |
| 3 | ... | ... | covered |
| 4 | ... | ... | optional |

### First 100 fans seed strategy
{concrete}

### Stoic guard-rails (vanity metrics to ignore)
- ...
- ...
```

---

## File 07 — `07-content-pillars.md`

**Purpose**: 3-5 content pillars with examples.

**Required sections**:

```markdown
# Content Pillars

## Pillar 1 — {name}
- **Theme**: ...
- **Audience awareness stage targeted**: {1-5}
- **% of calendar**: {X%}
- **Primary copy framework**: {PAS | AIDA | BAB | other}
- **3 example post topics**: ...

## Pillar 2 — {name}
[idem]

## Pillar 3 — {name}
[idem]

## (Optional) Pillar 4
## (Optional) Pillar 5

## Voice constraints (DO and DON'T)

### DO
- ...

### DON'T
- ...
```

---

## File 08 — `08-channel-strategy.md`

**Purpose**: per-channel cadence and tactical recommendations.

**Required sections**:

```markdown
# Channel Strategy

## Per-channel breakdown

### {Channel 1}
- **Cadence**: {N posts per week/day/month}
- **Format**: {long-form | thread | short | image | video}
- **Tone**: {tone description}
- **Pillar weighting**: {pillar 1: X%, pillar 2: Y%, ...}

### {Channel 2}
[idem]

## Visual content strategy (video — only if video channels retained)

- **Title formulas**: 3 per pillar
- **Thumbnail concepts**: 3
- **Opening hook patterns**: 3
- **Retention curve targets**: {benchmark}
```

---

## File 09 — `09-geo-plan.md`

**Purpose**: GEO audit and plan.

**Required sections**:

```markdown
# GEO Plan

## 7-lever audit

| # | Lever | Score 0-10 | Evidence |
|---|---|---|---|
| 1 | High-authority domain mention | X | ... |
| 2 | Statistical density | X | ... |
| 3 | Expert quotes | X | ... |
| 4 | Schema.org markup | X | ... |
| 5 | Extractable formatting | X | ... |
| 6 | Question-answering structure | X | ... |
| 7 | Freshness signals | X | ... |

## 3 weakest levers (highest improvement leverage)

1. **Lever {#}**: {name} — score {X} — leverage: ...
2. **Lever {#}**: ...
3. **Lever {#}**: ...

## Prescribed actions

### Action 1
- **What**: ...
- **Effort**: ...
- **Expected impact**: ...
- **Owner**: ...

### Action 2
[idem]

### Action 3
[idem]

## Measurement plan

- **Baseline test (5 queries × 4 LLMs)**: ...
- **Re-test cadence**: 60 / 90 / 180 days
- **Success criterion**: cited in ≥2 of 5 queries within 180 days
```

---

## File 10 — `10-instrumentation.md`

**Purpose**: NSM, attribution stack, kill-switch.

**Required sections**:

```markdown
# Instrumentation

## North Star Metric

- **NSM**: {name + one-sentence definition}
- **Why this NSM**: {captures value, not vanity}
- **Frequency of review**: {weekly | monthly}

## Input metrics (3-5)

| Input | Definition | Owner | Target | Frequency |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

## Attribution stack

### What we will track (and how)

| Channel | Last-click? | Multi-touch? | Best signal |
|---|---|---|---|
| ... | ... | ... | ... |

### Self-reported attribution

- **Form field**: {form name + position}
- **Categories**: {5-7 predefined}
- **Frequency of analysis**: {weekly | monthly}
- **Owner**: ...

### Branded search tracking

- **Tool**: {Ahrefs | SEMrush | Search Console}
- **Baseline**: {current monthly volume}
- **Target**: {+X% in 90 days}

## Kill-switch on attribution drift

- **Trigger**: {primary KPI drops Y% over Z weeks AND multi-touch doesn't explain}
- **Response**: trigger pivot review

## PG's first-100-users plan
{do-things-that-don't-scale concrete actions}
```

---

## File 11 — `11-content-calendar-90d.csv`

**Purpose**: 90 days of planned content slots.

**Schema (CSV columns)**:

```csv
date,channel,pillar,format,hypothesis,status
2026-04-29,LinkedIn,Pillar 1,long-form,"Test contrarian POV reframe",draft
2026-04-29,X,Pillar 2,thread,"...",draft
...
```

**Status values**: `draft` (default at packaging), `approved` (set by user), `posted` (set by executor), `archived`.

**Volume**: depends on cadence × 90 days. For example, 1 LinkedIn/day + 3 X/day = 90 + 270 = 360 rows.

---

## File 12 — `strategy-summary.md`

**Purpose**: 2-page exec summary for human review.

**Required sections**:

```markdown
# Strategy Summary — {product_name}

*Generated: {date}*

---

## 1. Diagnosis (Rumelt validator)

{One paragraph: what is the central challenge this product must address. Concrete, not abstract.}

## 2. Guiding Policy (Rumelt)

{One paragraph: the chosen approach. What it focuses on. What it explicitly EXCLUDES.}

## 3. Coherent Action (Rumelt)

The 3-5 mutually-reinforcing actions:
1. **Action 1**: ...
2. **Action 2**: ...
3. **Action 3**: ...
{...}

## 4. Primary KPI

- **NSM**: ...
- **90-day target**: ...

## 5. Top 3 risks

1. ...
2. ...
3. ...

## 6. Hypotheses to validate

(Things we don't know yet but the strategy depends on)

- ...
- ...
- ...

## 7. Hand-off

The detailed package is in `strategy/00` to `strategy/11`. The executor consumes `strategy/handoff-to-executor.yaml`.
```

---

## File 13 — `handoff-to-executor.yaml`

**Purpose**: structured contract for `promote-executor`. The executor reads this YAML + the markdown files referenced.

**Schema**: see `templates/handoff-to-executor.yaml.template` for the canonical structure.

Top-level keys:
- `campaign_id`
- `url`
- `product` (name, one_liner, jobs_to_be_done, unique_value_props)
- `icp` (primary, secondary)
- `offer` (current, hormozi_audit)
- `positioning` (one_sentence, contrarian_angle, proof_assets_to_create)
- `distribution` (primary_channels, secondary_channels, excluded with rationale)
- `content` (pillars, cadence per channel, voice)
- `goals` (primary_kpi, 90d_target, kill_switch_conditions)
- `hypotheses_to_validate`
- `unknowns`
- `geo_plan_summary`
- `instrumentation_summary`
