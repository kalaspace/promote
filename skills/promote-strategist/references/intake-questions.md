# Intake Questions — the 5 batches of P1 (v1.3.0)

The strategist asks ONLY about THE PRODUCT. It NEVER asks about marketing method, channels, frequency, or copy frameworks — those are the strategist's decisions.

For each question : the **intent** (what we'll use it for), the **skip condition** (don't ask if already known), and (where ambiguous) the **rationale** if user pushes back ("why are you asking this?").

**v1.3.0 note** : after P1 (all 5 batches answered), the strategist runs **P1.5 Claims Extraction & Validation** (see `pipeline-phases.md`) to build `intake/verified-claims.csv` from the batch responses. The user reviews the extracted ledger in 15 min before P2 starts. This prevents the v1.2.0 hallucination problem (operators inventing process details not in intake). Authors should be **specific and concrete** in their batch answers — vague answers ("I think I started maybe a year ago") become claims `confidence=LOW` that won't be usable as sources downstream. Specific answers ("started October 2024 with this prompt:...") become `confidence=HIGH` and unlock high-fidelity content production.

---

## Batch 1 — Product & Usage (6-8 questions)

### Q1.1 — Product one-liner
> *"In one sentence, what does the product do?"*

- **Intent**: feeds positioning, pitch, copy.
- **Skip if**: hero copy from P0 already gives a clean one-liner.

### Q1.2 — Job-to-be-done
> *"What is the user actually trying to accomplish when they use the product? Not the feature — the underlying job."*

- **Intent**: input to `promote-jtbd-switch`. Critical.
- **Skip if**: rare. Always ask unless P0 explicitly captured a JTBD statement.
- **Rationale if pushed**: Features change, jobs don't. We position around the job.

### Q1.3 — Day before vs day after
> *"Describe a day in the life of the ideal user — BEFORE they had this product. Then AFTER. Specific moments, not abstract benefits."*

- **Intent**: input to JTBD, copy work, content pillars.

### Q1.4 — The hidden critical feature
> *"What feature does almost no one notice in the marketing — but is what actually makes the product work? The thing power users say 'wait, you don't see X? that's the real magic'."*

- **Intent**: positioning differentiation. Most marketing leads with the wrong feature.
- **Rationale if pushed**: surface features attract clicks; hidden features close deals. We need to know both.

### Q1.5 — Technical primitive
> *"What is the underlying technical primitive (or method, or insight) that makes this product possible? Not the wrapper — the core thing."*

- **Intent**: input to category design, GEO citation strategy, content authority pillars.

### Q1.6 — What it CAN'T do (yet)
> *"What does the product NOT do well today, but users routinely expect? The known gap."*

- **Intent**: claims-to-avoid list. Honest copy outperforms over-claim.

### Q1.7 — Time-to-value
> *"How long does it take a brand-new user to reach their first 'wow' moment? Be specific — minutes, hours, days?"*

- **Intent**: input to `promote-plg-design` (TTV is the central PLG variable).
- **Skip if**: P0 captured this from product page.

### Q1.8 — The 'in-house tool' origin (if applicable)
> *"Was this built originally to solve YOUR own problem? If yes, describe."*

- **Intent**: founder narrative, often the strongest content pillar.

---

## Batch 2 — ICP & Market (5-7 questions)

### Q2.1 — Real current buyers (not idealized)
> *"WHO is actually buying today? Be specific: roles, company size, industry, country. The real ones, not the aspirational ones."*

- **Intent**: ICP grounding.

### Q2.2 — Switch interview moment of struggle
> *"Pick one recent buyer. What was the SPECIFIC situation that made them say 'I can't keep doing this, I need a tool'? Not the year, not the trend — the exact moment of struggle."*

- **Intent**: input to `promote-jtbd-switch`'s 4 Forces.
- **Rationale if pushed**: People don't buy because the year changed. They buy because of a moment. We need that moment.

### Q2.3 — Who buys but shouldn't (mismatch)
> *"Are there users who BUY but turn out to not be a good fit? Who churns fast or asks for refunds?"*

- **Intent**: ICP exclusion list. Equally important.

### Q2.4 — Current category
> *"How do users describe the category to themselves and to others? 'It's like X but for Y' — what's their X?"*

- **Intent**: input to `promote-dunford-positioning`'s 5+1 building blocks.

### Q2.5 — Alternatives compared
> *"What 2-3 alternatives do prospects compare you to? Including 'do nothing' if relevant."*

- **Intent**: positioning, competitive analysis.

### Q2.6 — Personal vs business spend
> *"Is the buyer paying with their own money, with a department budget, or with corporate budget through procurement?"*

- **Intent**: pricing model fit (PLG vs sales-assist vs enterprise).

### Q2.7 — Audience growing or shrinking
> *"Is the audience for this kind of solution growing, flat, or shrinking? What's the trend?"*

- **Intent**: market/product fit (Balfour's 1st fit). Critical signal.

---

## Batch 3 — Pricing & Economics (4-6 questions)

### Q3.1 — Current pricing
> *"What's the price today? And what variants have you tested?"*

- **Intent**: foundation for offer audit (Hormozi).
- **Skip if**: P0 captured pricing page.

### Q3.2 — LTV estimate
> *"Estimated lifetime value per customer? If you don't know precisely, give a range."*

- **Intent**: unit economics gate for PLG, channel/model fit.
- **'I don't know' is OK**: mark as `hypothesis_to_validate`.

### Q3.3 — Gross margin
> *"Gross margin per sale, roughly? After cost of goods / cost of service."*

- **Intent**: same as LTV.

### Q3.4 — Acceptable CAC
> *"What's an acceptable customer acquisition cost? In rough numbers — what could you spend to acquire one customer and still be profitable?"*

- **Intent**: channel economics gate.

### Q3.5 — Discount / promo strategy
> *"Do you currently discount? When? Why?"*

- **Intent**: avoid offer-cannibalization; alignment with Schwartz's awareness-stage strategy.

### Q3.6 — Free tier or trial
> *"Is there a free tier or trial? What does it include and how long?"*

- **Intent**: PLG mode selection (`promote-plg-design`).

---

## Batch 4 — Social Proof & Existing Assets (4-6 questions)

### Q4.1 — Quantified testimonials
> *"What testimonials do you have, especially WITH NUMBERS? '+47% conversion in 30 days' kind of stuff. Even if rough."*

- **Intent**: GEO statistical-density lever, social proof copy.

### Q4.2 — Before/after captures
> *"Are there screenshots, dashboards, or data showing user results before/after?"*

- **Intent**: same.

### Q4.3 — Existing posts/videos
> *"Have you already published content about the product (posts, videos, podcasts, blog posts)? Roughly how many, on what platforms?"*

- **Intent**: voice library for `promote-ai-content-pipeline`. If <20, voice-fingerprinting must precede content scaling.

### Q4.4 — Press / podcasts already covered
> *"Has any press, blog, or podcast already covered the product?"*

- **Intent**: input to `promote-holiday` (TUTC chain — what tier is already covered).

### Q4.5 — Notable users / customers
> *"Are there well-known users or customers? Even if 'small-name' but recognizable in the niche."*

- **Intent**: authority signal, GEO lever.

### Q4.6 — Existing community
> *"Is there a Slack, Discord, mailing list, or other community where users gather?"*

- **Intent**: word-of-mouth seed network, demand-creation channel.

---

## Batch 5 — Voice, Constraints, Goals (4-6 questions)

### Q5.1 — 90-day primary goal
> *"What's the ONE primary goal for the next 90 days? Awareness, leads, sales, retention, expansion? Pick one."*

- **Intent**: NSM and KPI selection. Critical for strategy synthesis.

### Q5.2 — 90-day target
> *"What's the numeric target for that goal? '10K signups,' '20 SQLs/week,' '$50K MRR added,' etc."*

- **Intent**: validates feasibility, tunes strategy aggressiveness.

### Q5.3 — Forbidden claims
> *"Are there claims you legally or ethically can't make? (Medical, financial, regulatory.)"*

- **Intent**: copy guardrails. Critical to capture upfront.

### Q5.4 — Brand tone
> *"Tone of brand voice in 3 words: formal/casual, contrarian/safe, technical/accessible."*

- **Intent**: voice fingerprint for content production.

### Q5.5 — Existing channels + Channel exploration
> *"(A) What social/community channels already exist for this product or for the founder? List them with rough audience size. (B) Are there channels you'd LIKE to explore but haven't yet? (E.g., email list, YouTube, Discord, TikTok, Substack, podcast guesting, paid ads on Meta/Google, etc.) — even if no infrastructure yet."*

- **Intent**: channel mix decision (re-use vs build vs new-to-test).
- **Rationale if pushed**: We want to know both what's working AND what's dormant. The strategist will recommend which sleeping channels to test, plus PROPOSE channels you didn't think of via `promote-channel-strategist`.

### Q5.6 — Hard 'no' channels
> *"Are there channels you refuse to use? (E.g., 'never TikTok', 'no LinkedIn'.) Why?"*

- **Intent**: respect the constraint; document the reason for hand-off to executor.

### Q5.7 — Product type (NEW v1.1.0)
> *"Type de produit principal: B2B SaaS / B2C SaaS / DTC e-commerce / digital course / livre / service / mobile app / autre? Plus précis = mieux."*

- **Intent**: guide channel-strategist routing. B2B SaaS = LinkedIn/email/podcast lourd ; DTC = Meta/TikTok/Amazon paid ; mobile app = Seufert + UA-specific ; livre = Substack + Reddit + Pinterest.
- **Skip if**: Q1.1 et Q2.1 ont déjà clarifié.

---

## Skip rules (apply across all batches)

A question is **skipped** if:
1. The answer is already in `STATE.known_facts` from P0 crawl.
2. The answer is logically derivable from a prior batch's answer.
3. The user explicitly said "skip" or "don't know" earlier and the same question reappears.
4. In **autopilot mode**: ALL questions are skipped; the strategist generates `ASSUMED:` values and marks them in `hypotheses_to_validate`.

A question is **deferred** (asked at end of batch) if:
1. It logically depends on an answer the user hasn't given yet.

A question is **mandatory** (cannot be skipped) if marked above as critical (Q1.2, Q2.1, Q5.1). If user says "skip" on a mandatory, the strategist explains why it can't proceed without it and re-poses.
