# Completeness Checklist — 30 points (P5 quality gate v1.4.0)

Run this checklist after P5 packaging. Compute pass percentage.
- ≥90% (≥27/30) → ship.
- 70-89% (21-26/30) → loop back to weakest phase, retry once.
- <70% (<21/30) → escalate to user with detailed gap report.

**v1.4.0 changes vs 28-point v1.3.0**:
- **Added Section M (NEW v1.4.0, 2 points)** : Product content ingestion + STRUCTURE/EXAMPLES grounding rate.
- Section L expanded from 4 → 4 points (unchanged but with v1.4.0 mentions).
- Section K updated for full-window calendar (no more outline status).

---

## Section A — Product brief (5 points)

- [ ] A1. Product one-liner is one sentence, no jargon (`00-product-brief.md`).
- [ ] A2. Job-to-be-done is described (not just feature).
- [ ] A3. Day-before / day-after vivid (`00-product-brief.md`).
- [ ] A4. Hidden critical feature identified (or marked `unknown`).
- [ ] A5. Forbidden claims explicitly listed (or "none") AND match `intake/never-claims.txt`.

## Section B — Market research (4 points)

- [ ] B1. Top 3 competitors with positioning + pricing (`01-market-research.md`).
- [ ] B2. ICP at least 1 persona with demo + psycho + JTBD.
- [ ] B3. Category mode determined (Better | Different | Different+Cat-creation).
- [ ] B4. Category stage determined (cold/tipping/escape/mature/decline).

## Section C — JTBD analysis (3 points)

- [ ] C1. 4 Forces (push, pull, anxiety, habit) all populated (`02-jtbd-switch.md`).
- [ ] C2. Moment of struggle is specific (not generic).
- [ ] C3. 3 dimensions (functional, emotional, social).

## Section D — Positioning (3 points)

- [ ] D1. Dunford 5+1 components present (`03-positioning.md`).
- [ ] D2. One-sentence positioning statement (≤20 words).
- [ ] D3. Contrarian POV (Ammar) is NOT a paraphrase of standard.

## Section E — Offer & awareness (3 points)

- [ ] E1. Value Equation 4 dimensions scored (`04-offer-audit.md`).
- [ ] E2. Awareness stage diagnosed (1-5).
- [ ] E3. Mass desire identified in one sentence.

## Section F — Growth fits & GTM (2 points)

- [ ] F1. 4 fits scored + bottleneck identified + ONE prescribed action (`05-growth-fits.md`).
- [ ] F2. PLG model chosen with unit economics gate (only if software).

## Section G — Distribution & content (3 points)

- [ ] G1. Primary channels rank-ordered ≥3 (`06-distribution-plan.md`).
- [ ] G2. Excluded channels have explicit reasons.
- [ ] G3. Tradeoffs résolus + narrative_hypotheses_requiring_confirmation sections present.

## Section H — Pillars + content (2 points)

- [ ] H1. 3-5 content pillars with `awareness_stage` Schwartz tag (`07-content-pillars.md`).
- [ ] H2. Schwartz distribution check: max 30% of 14d concrete posts in any single stage (NEW v1.3.0).

## Section I — Channel strategy (1 point)

- [ ] I1. Cadence per primary channel (`08-channel-strategy.md`).

## Section J — Tripwires top-3 (1 point)

- [ ] J1. 3 KPIs with thresholds + owner (`10-tripwires-top3.md`). NSM not vanity.

## Section K — Calendar & summary (2 points)

- [ ] K1. `11-content-calendar-Nd-full.csv` populated for the full window (default 90d). All slots `status='concrete'` or `status='manual_review_needed'`. NO outline status v1.4.0.
- [ ] K2. `strategy-summary.md` has all sections (Rumelt 1-3, KPI, risks, hypotheses, tradeoffs, hand-off, manual_review_needed_count).

## Section L — Claims hygiene (v1.3.0+v1.4.0, 4 points)

- [ ] L1. `intake/verified-claims.csv` exists with ≥30 rows v1.4.0 (≥10 if product-content.md MISSING) + `verified_by_user` column populated. Includes STRUCTURE+EXAMPLES claims if product-content.md COMPLETE.
- [ ] L2. `intake/never-claims.txt` exists with v1.4.0 default entries (chapter-fabrication blockers, etc.).
- [ ] L3. For each `.md` in `content/posts/`: cross-check `factual_claims_used` in adjacent `.meta.yaml` ; all claim_ids referenced exist in ledger ; 0 unverified claims ; 0 reject_immediate.
- [ ] L4. For each `.md` in `content/posts/`: NO `{...}` placeholders in body (Reject-on-placeholder rule).

## Section M — Source-truth grounding (NEW v1.4.0, 2 points)

- [ ] M1. `intake/product-content.md` exists with `STATE.product_content_completeness = COMPLETE` (or PARTIAL with documented gaps). Sections per product_type (chapters/modules/features/cases) populated with structured entries.
- [ ] M2. Grounding rate ≥ 80% : count of `.meta/{slug}.yaml` files with `gate_7_factual_claims_check.grounding_check_7_1.pass: true` divided by count of PRODUCT_PROMOTION posts. If grounding rate < 80% → most PRODUCT_PROMOTION posts ungrounded → critical fail.

---

## Total: 30 points

- 27-30 (≥90%) → SHIP. Set `STATE.status = ready-for-executor`.
- 21-26 (70-89%) → identify weakest section, loop back once. Common loop targets:
  - Section C/D weak → re-run P3.A.2/A.3 (JTBD or Dunford).
  - Section E weak → re-run P3.A.4/A.5 (Hormozi or Schwartz).
  - Section F weak → re-run P3.A.7/A.8 (Four Fits or PLG).
  - Section G weak → re-run P3.B/C/D (channel-strategist + consultations + refinement).
  - Section H weak → re-run P3.E (pillars consolidation, especially Schwartz routing).
  - Section L weak → P1.5 ledger review + Quality Gate #7 fact-check loop.
  - Section M weak → re-run P0.5 product-content-ingestion (more chapters/modules from product) + P1.5 re-extraction.
- ≤20 (<70%) → ESCALATE. Output gap report to user, ask if they want to continue or abort.

## Pattern #11 audit (run alongside, not separately scored)

For EACH artifact in `strategy/` AND each `.md` in `content/posts/`, count occurrences of:
- "which means that"
- "this is because"
- "what this means for you"
- "in other words"
- "essentially this..."
- "...the kind of [...] that..."

If any artifact has >2 occurrences → flag as `pattern_11_violation`. Re-generate with anti-extension instruction. Counts toward the relevant section's gate but doesn't have its own line item.

## Changelog

- **0.3.0** (2026-05-01) — v1.4.0. Added Section M (source-truth grounding, 2 points) tied to product-content.md ingestion + Quality Gate #7.1 grounding rate. Updated Section K for full-window calendar (no outline status). Total now 30 points.
- **0.2.0** (2026-05-01) — v1.3.0. Trimmed from 40 to 28 points (cut Geo audit, trimmed instrumentation, folded Pattern #11). Added Section L (claims hygiene) with 4 checks tied to verified-claims.csv + never-claims.txt + Quality Gate #7 results.
- **0.1.0** (2026-04-28) — v1.0.0/1.1.0/1.2.0. 40-point checklist.
