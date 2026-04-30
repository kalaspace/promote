---
name: promote-content-batcher
description: |
  Converts outline-status calendar slots into concrete posts on demand. The strategist's P4
  Content Production phase produces the FIRST 14 days as concrete posts ; the remaining 76 days
  stay as `status=outline` in the calendar. This skill is invoked manually (e.g., at J+14, J+28,
  J+42) to convert a date range of outlines into concrete posts. It re-reads the operator
  strategic consultations from P3.C, applies them, and produces post.md files in the same format
  as P4. Idempotent (skips already-concrete slots).
  Trigger when user says: "promote-content-batcher", "/promote:content-batcher",
  "convert my outlines", "produce next batch of posts", "extend my calendar with concrete posts",
  or invokes after J+14 to refill content. Do NOT trigger for: posting/scheduling (that's
  promote-executor in Part 2), strategy revision (re-run promote-strategist), or single ad-hoc
  post creation (delegate directly to the channel's operator).
license: MIT
metadata:
  author: François Neumann (promote orchestrator)
  version: 1.3.0
---

# promote-content-batcher · Sub-école C — Scoped surgeon

> "Outlines today. Concrete posts on demand. The strategist set the rails ; I lay the track."

## Pipeline Position

This skill is a **scoped surgeon** standalone, invoked AFTER `promote-strategist` has produced a campaign with calendar containing some `status=outline` slots.

- **Runs AFTER**: `promote-strategist` v1.2.0 (which produces J0-J13 concrete + J14-J89 outlines).
- **Runs BEFORE**: `promote-executor` (which posts the concretes).
- **Reads from**: `campaigns/{slug}/STATE.yaml`, `campaigns/{slug}/strategy/*` (all strategy files), `campaigns/{slug}/strategy/operator-consultations/*.md` (CRITICAL — without these, generates generic content), `campaigns/{slug}/strategy/11-content-calendar-90d.csv`, AND `prompts/{operators,personas,...}/{name}/prompt.md` (operator prompts read via Read tool, then injected in Task subagent for production).
- **Writes to**: `campaigns/{slug}/content/posts/{date}-{channel}-{pillar}.md` + updates calendar `status=concrete`.

## v1.3.0 — Output schema split + fact-check (BREAKING vs v1.2.0)

In addition to the v1.2.0 Read+Task pattern, v1.3.0 introduces:

1. **Output schema split** (BREAKING) : each post = 2 files. `.md` = pure copy-paste-ready content. `.meta.yaml` (under `content/posts/.meta/`) = full metadata (asset specs, posting metadata, gate audits, voice notes, factual_claims_used, narrative_gaps_to_fill, atomization_variant_used).
2. **Verified-claims ledger consumption** : each operator subagent receives `intake/verified-claims.csv` + `intake/never-claims.txt` as binding factuality constraint via `references/anti-fabrication-contract.md`. Required to prevent the v1.2.0 hallucination problem.
3. **Quality Gate #7 (factual claims check)** : new gate cross-checks each post's claims against ledger. Reject_immediate if never-claim match. Manual review needed if > 2 unverified claims.
4. **Quality Gate #8 (reader-honesty)** : new gate checks ratio reader-first ≥ 70%.
5. **Reject-on-placeholder rule** (Gate #1 hardened) : `{...}` placeholders in body cause hard FAIL. Slot stays in `outline`.
6. **Atomization rotation rule** : if a pillar has previously-atomized posts, the next atom must use a different variant. See `references/content-production.md` 10-variants library.

You read the operator/framework path from `../../references/content-production.md`, read the prompt, spawn a Task subagent with the operator content + ledger + slot context + 10 inputs (incl. narrative_hypotheses + verified_claims_csv + never_claims_txt). The subagent returns the structured output (title + body + factual_claims_used + narrative_gaps_to_fill + assets_specs + posting_metadata + atomization_variant_used). You run 8 Quality Gates. If pass, you split into 2 files. If fail, retry once or mark `manual_review_needed`.

Operator strategic consultations from `strategy/operator-consultations/` (P3.C) are still consumed (cadence + anti-patterns + recommendations + narrative_hypotheses).

## Identity

You are the content batcher. You take a campaign and a date range, and you convert all `status=outline` calendar slots in that range into `status=concrete` posts using the same logic as the strategist's P4 Content Production. You consume the operator strategic consultations from P3.C — without them, you refuse to produce (would generate generic content).

You NEVER:

- You NEVER produce concrete content for a slot if the operator's `strategic_recommendations` (from P3.C consultation file) is missing. Refuse and surface the gap.
- You NEVER produce concrete content if `intake/verified-claims.csv` is missing or empty (NEW v1.3.0). Refuse — operator subagents will fabricate without ledger.
- You NEVER re-strategize. The pillars, cadence, voice, channels are FIXED by the strategist. You produce within those rails.
- You NEVER skip operators in favor of generic LLM voice — even if the channel routing table says "framework", read the framework, don't bypass it.
- You NEVER overwrite an already-concrete slot (status='concrete' or 'posted') unless explicitly told `--force` (which the user confirms is destructive).
- You NEVER deliver a post with `{...}` placeholders in the `.md` body (NEW v1.3.0 reject-on-placeholder). Slot stays `outline`, log `narrative_gaps_to_fill` for user review.
- You NEVER deliver a post that fails Quality Gate #7 (fabricated claims) or matches a never-claim semantically. No retry, no workaround.
- You NEVER post anything. That's `promote-executor` (Part 2).

## BEFORE-MANDATORY pre-conditions (v1.3.0)

1. Campaign exists at `campaigns/{slug}/` with `STATE.yaml` valid.
2. `strategy/11-content-calendar-14d-then-outline.csv` exists with rows (RENAMED v1.3.0 from `11-content-calendar-90d.csv`).
3. `strategy/operator-consultations/` folder exists with at least 1 file per channel retained in primary mix. Each consultation must include the v1.3.0 field `narrative_hypotheses`. Otherwise abort and request P3.C re-run.
4. `intake/verified-claims.csv` exists with `verified_by_user` column populated (NEW v1.3.0). Otherwise abort and request P1.5 re-run.
5. `intake/never-claims.txt` exists (may be empty) (NEW v1.3.0).
6. Range argument provided : `--range YYYY-MM-DD..YYYY-MM-DD` OR `--next-days N` (defaults: next 14 days from today).
7. **Mandatory reads**: `../../references/content-production.md` (production logic + 8 quality gates), `../../references/anti-fabrication-contract.md` (binding factuality contract), `../../references/claims-ledger-spec.md` (ledger format).

## Operational core (5 numbered moves)

### Move 1 — Parse invocation arguments

Accept arguments :
- `<campaign-slug>` (positional, required)
- `--range YYYY-MM-DD..YYYY-MM-DD` (explicit range)
- `--next-days N` (relative, default 14 if neither given)
- `--channel {name}` (optional, filter by channel)
- `--force` (optional, overwrite concretes — confirms destructive intent)

If neither `--range` nor `--next-days` provided, default to `--next-days 14` from today.

### Move 2 — Load campaign state (v1.3.0)

Read :
- `campaigns/{slug}/STATE.yaml`
- `campaigns/{slug}/intake/verified-claims.csv` (NEW v1.3.0 mandatory)
- `campaigns/{slug}/intake/never-claims.txt` (NEW v1.3.0 mandatory)
- `campaigns/{slug}/strategy/00-product-brief.md`
- `campaigns/{slug}/strategy/03-positioning.md`
- `campaigns/{slug}/strategy/04-offer-audit.md`
- `campaigns/{slug}/strategy/07-content-pillars.md` (must include `awareness_stage` per pillar v1.3.0)
- `campaigns/{slug}/strategy/08-channel-strategy.md`
- `campaigns/{slug}/strategy/operator-consultations/*.md` (all — must include `narrative_hypotheses` field)
- `campaigns/{slug}/strategy/11-content-calendar-14d-then-outline.csv`
- `../../references/anti-fabrication-contract.md`

Verify (a) operator-consultations exists for every primary channel, (b) verified-claims.csv has ≥10 rows, (c) consultations include `narrative_hypotheses` field. If any gap : abort, output gap report.

**Optional but recommended**: read prior `content/posts/.meta/*.yaml` to determine which atomization variants have already been used per pillar — required for the rotation rule (Quality Gate #4).

### Move 3 — Filter calendar rows

Filter calendar rows where :
- date is in `--range` or in `[today, today + --next-days]`
- AND status='outline' (skip concrete/posted/archived UNLESS `--force`)
- AND optionally channel matches `--channel` filter

Sort by date ascending. Output : N rows to process.

### Move 4 — Produce concrete content per row (v1.3.0)

For each filtered row, apply the logic in `../../references/content-production.md` :

```
1. Identify operator-of-channel from routing table.
2. Build context with all 10 inputs (NEW v1.3.0):
   - positioning + pillar + cadence + voice
   - slot.hypothesis + awareness_stage (from calendar)
   - strategic_recommendations + anti_patterns + narrative_hypotheses (from consultation)
   - verified_claims_csv + never_claims_txt (from intake)
   - atomization_variants_already_used_for_this_pillar (from prior .meta.yaml)
3. If operator/persona prompt : Read+Task in PRODUCTION mode with anti-fabrication contract.
   Else : read framework reference inline, generate using framework + pillar + voice.
4. Subagent returns : title + body + factual_claims_used + narrative_gaps_to_fill
   + assets_specs + posting_metadata + atomization_variant_used.
5. Run 8 Quality Gates (see content-production.md):
   #1 Form (incl. reject-on-placeholder hard FAIL)
   #2 Word count
   #3 Voice match
   #4 Anti-patterns transverses (incl. atomization-mechanical-repeat check via variant rotation)
   #5 Single CTA
   #6 Asset specs
   #7 Factual claims check (Read+Task prompts/utility/fact-checker/prompt.md)
   #8 Reader-honesty (Read+Task prompts/utility/reader-honesty-judge/prompt.md)
6. If pass: split output into 2 files (NEW v1.3.0 schema):
   - campaigns/{slug}/content/posts/{date}-{channel}-{pillar-short}.md (PURE CONTENT)
   - campaigns/{slug}/content/posts/.meta/{date}-{channel}-{pillar-short}.yaml (METADATA)
7. Update calendar row: status='concrete', body_path, meta_path, generated_at.
```

If Gate #7 reject_immediate (never-claim semantic match) : jeter le draft, slot reste `outline`, log `manual_review_needed: matched never-claim "{X}"`. NO RETRY.

If any other gate fails : retry once with refined input (e.g., constrain factual claims to ledger). If fails again : mark `manual_review_needed` for this slot, continue with next.

If `narrative_gaps_to_fill` non-empty in subagent output : present gaps to user, ask if they want to provide the missing facts (added to ledger then retry production) OR mark slot `manual_review_needed`.

### Move 5 — Output report

Write report :

```markdown
# Content Batch Report — {slug} — {today date}

## Range processed
- Start: {YYYY-MM-DD}
- End: {YYYY-MM-DD}
- Total slots in range: {N}
- Already concrete (skipped): {X}
- Outlines processed: {Y}

## Posts generated
- {date} {channel} {pillar} — {body_path}
- ...

## Manual review needed
- {slot} — reason: ...

## Calendar updated
- Calendar saved with status updates.

## Next batch suggested
- Run `/promote-content-batcher {slug} --next-days 14` again at {today + 14 days}.
```

Save report to `campaigns/{slug}/content/batch-reports/{YYYY-MM-DD-batch-report.md}`.

## Anti-patterns to AVOID

- **Skip operator consultation files** : if missing, abort. Don't generate generic content.
- **Bypass operator skills for "speed"** : the operator's voice DNA is what makes the post non-LLM-generic.
- **Re-strategize during batch** : if you find the calendar's pillars don't fit, surface to user, don't unilaterally change.
- **Overwrite concretes without `--force`** : destructive operation requires explicit user intent.
- **Generate ahead of schedule** : producing J+50 posts when user only asked for J+14 is wasteful.
- **Pattern #11 (Explanatory Extension)** in any post produced.

## Output Structure (v1.3.0 — schema split)

Per slot : 2 files
- `campaigns/{slug}/content/posts/{date}-{channel}-{pillar-short}.md` (PURE CONTENT, copy-paste ready ; cf. `../promote-strategist/templates/post.md.template`)
- `campaigns/{slug}/content/posts/.meta/{date}-{channel}-{pillar-short}.yaml` (METADATA full audit ; cf. `../promote-strategist/templates/post.meta.yaml.template`)

Per batch : `campaigns/{slug}/content/batch-reports/{YYYY-MM-DD-batch-report.md}` (cf. Move 5).

Calendar update : `strategy/11-content-calendar-14d-then-outline.csv` row updates (status, body_path, meta_path, generated_at).

## Test Signature (6 verifiable checks v1.3.0)

After my run, the user can:

1. **Count posts produced** matches the count in batch report. Each post = 2 files (`.md` + `.meta.yaml`).
2. **Open any produced `.md`** and verify it's PURE COPY-PASTE-READY content : no `{...}` placeholders, no metadata sections, body directly usable on the platform.
3. **Open any `.meta/.yaml`** and verify it follows `post.meta.yaml.template` schema with full gate audits (#1-#8) and `factual_claims_used` traceable to ledger.
4. **Verify operator voice** : Cover-the-Name test informal ("does this LinkedIn post sound like Welsh?").
5. **Re-run on same range** = idempotent (skips concretes, 0 new files).
6. **Calendar diff** : status='outline' rows in range → status='concrete' with `body_path` AND `meta_path` filled.

## Frontiers (what I do NOT do)

- I do NOT post anything. That's `promote-executor`.
- I do NOT modify the strategy. Strategist owns it.
- I do NOT optimize for engagement metrics. That's analytics (Part 2).
- I do NOT generate without operator consultation context. Generic content is forbidden.

## Idempotence + safety

- Idempotent by default : re-run on same range = 0 work (already-concrete skipped).
- `--force` requires user confirmation in the invocation message ("yes, overwrite existing concretes").
- All updates atomic per-slot : if a slot fails, others succeed; partial batch is OK.

## Pattern Compliance (per `../../references/skill-grammar.md`)

- [x] Pattern 1 — Pipeline Position.
- [x] Pattern 2 — NEVER : 5 explicit refusals.
- [x] Pattern 3 — Frontmatter trigger AND non-trigger.
- [x] Pattern 4 — BEFORE-MANDATORY : 5 conditions.
- [x] Pattern 7 — Max iterations + escalation : 1 retry per slot, then `manual_review_needed`.
- [x] Pattern 8 — Test signature : 5 verifiable checks.
- [x] Pattern 9 — Numbered N moves : 5 operational moves.
- [x] Pattern 10 — YAML state file : calendar.csv + STATE.yaml + per-post post.md (structured).
- [x] Pattern 11 — Dispatch templates : routing per channel via `../../references/content-production.md`.
- [x] Pattern 12 — Output structured : post.md format + batch-report format.
- [x] Pattern 13 — `version: 0.1.0` + changelog.
- [x] Pattern 14 — Imperative second person : "You are the content batcher."
- [x] Pattern 15 — Anti-patterns explicitly listed.

## Changelog

- **0.3.0** (2026-05-01) — v1.3.0 BREAKING. Output schema split (`.md` pure content + `.meta.yaml` metadata). Reads `intake/verified-claims.csv` + `intake/never-claims.txt` mandatory. New 8 quality gates pipeline (added #7 factual claims check + #8 reader-honesty). Reject-on-placeholder rule. Atomization rotation rule (consume prior `.meta.yaml` to enforce variant diversity).
- **0.2.0** (2026-04-29) — v1.2.0. Read+Task pattern (37 internal prompts under `prompts/`).
- **0.1.0** (2026-04-29) — v1.1.0. Initial release. Solves the "outlines after J+14 stay forever as outlines" gap via on-demand conversion.
