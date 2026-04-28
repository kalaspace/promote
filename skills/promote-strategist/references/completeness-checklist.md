# Completeness Checklist — 40 points (P4 quality gate)

Run this checklist after P4 packaging is complete. Compute pass percentage.
- ≥90% → ship.
- 70-89% → loop back to weakest phase, retry once.
- <70% → escalate to user with detailed gap report.

---

## Section A — Product brief (5 points)

- [ ] A1. Product one-liner is one sentence, no jargon (`00-product-brief.md`).
- [ ] A2. Job-to-be-done is described (not just feature).
- [ ] A3. Day-before / day-after vivid (`00-product-brief.md`).
- [ ] A4. Hidden critical feature identified (or marked `unknown`).
- [ ] A5. Forbidden claims explicitly listed (or "none").

## Section B — Market research (4 points)

- [ ] B1. Top 3 competitors with positioning + pricing (`01-market-research.md`).
- [ ] B2. ICP at least 1 persona with demo + psycho + JTBD.
- [ ] B3. Category mode determined (Better | Different | Different+Cat-creation).
- [ ] B4. Category stage determined (cold/tipping/escape/mature/decline).

## Section C — JTBD analysis (3 points)

- [ ] C1. 4 Forces (push, pull, anxiety, habit) all populated (`02-jtbd-switch.md`).
- [ ] C2. Moment of struggle is specific (not generic).
- [ ] C3. 3 dimensions (functional, emotional, social).

## Section D — Positioning (4 points)

- [ ] D1. Dunford 5+1 components present (`03-positioning.md`).
- [ ] D2. One-sentence positioning statement (≤20 words).
- [ ] D3. Contrarian POV (Ammar) is NOT a paraphrase of standard.
- [ ] D4. Category-creation POV present (only if mode is category-creation).

## Section E — Offer & awareness (4 points)

- [ ] E1. Value Equation 4 dimensions scored (`04-offer-audit.md`).
- [ ] E2. Awareness stage diagnosed (1-5).
- [ ] E3. Sophistication level diagnosed (1-5).
- [ ] E4. Mass desire identified in one sentence.

## Section F — Growth fits & GTM (4 points)

- [ ] F1. 4 fits scored (`05-growth-fits.md`).
- [ ] F2. Bottleneck identified.
- [ ] F3. ONE action prescribed (not three).
- [ ] F4. PLG model chosen with unit economics gate (only if software).

## Section G — Distribution & content (5 points)

- [ ] G1. Primary channels rank-ordered ≥3 (`06-distribution-plan.md`).
- [ ] G2. Excluded channels have explicit reasons.
- [ ] G3. Demand creation vs capture split with rationale.
- [ ] G4. TUTC chain has 4 tiers with outlets (`06-distribution-plan.md` Holiday section).
- [ ] G5. First 100 fans seed strategy is concrete.

## Section H — Pillars (3 points)

- [ ] H1. 3-5 content pillars (`07-content-pillars.md`).
- [ ] H2. Each pillar has audience awareness stage + copy framework.
- [ ] H3. 3 example post topics per pillar.

## Section I — Channel strategy & GEO (3 points)

- [ ] I1. Cadence per primary channel (`08-channel-strategy.md`).
- [ ] I2. GEO 7-lever audit + 3 prescribed actions (`09-geo-plan.md`).
- [ ] I3. GEO baseline test instructed.

## Section J — Instrumentation (3 points)

- [ ] J1. NSM identified, NOT a vanity metric (`10-instrumentation.md`).
- [ ] J2. 3-5 input metrics with owners.
- [ ] J3. Self-reported attribution mechanism designed.

## Section K — Calendar & summary (2 points)

- [ ] K1. `11-content-calendar-90d.csv` populated for at least 2 weeks (or marked partial).
- [ ] K2. `strategy-summary.md` has all 7 sections (Rumelt 1-3, KPI, risks, hypotheses, hand-off).

---

## Total: 40 points

- 36-40 (≥90%) → SHIP. Set `STATE.status = ready-for-executor`.
- 28-35 (70-89%) → identify weakest section, loop back once. Common loop targets:
  - Section C/D weak → re-run step b/c (JTBD or Positioning).
  - Section E weak → re-run step d/e (Hormozi or Schwartz).
  - Section F weak → re-run step g/h (Four Fits or PLG).
  - Section G weak → re-run step j/n (X-Mastery or Holiday).
- ≤27 (<70%) → ESCALATE. Output gap report to user, ask if they want to continue or abort.

## Pattern #11 sub-check (run alongside)

For EACH artifact in `strategy/`, count occurrences of:
- "which means that"
- "this is because"
- "what this means for you"
- "in other words"
- "essentially this..."
- "...the kind of [...] that..."

If any artifact has >2 occurrences → flag as `pattern_11_violation`. Re-generate with anti-extension instruction.
