# Pipeline Phases — `promote-strategist`

Detailed specification of each of the 5 phases. Companion to the main SKILL.md.

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

## P3 — STRATEGY SYNTHESIS

**This is the heart of the pipeline.** 15 delegations executed in order. See `delegation-matrix.md` for the verbatim invocation prompt for each.

The skills invoked, in order:

| Step | Skill or Reference | Type |
|---|---|---|
| a | `../../../references/strategy-kernel.md` | Read (validator AMONT) |
| b | `promote-jtbd-switch` | Skill |
| c | `../../../references/category-design.md` THEN `promote-dunford-positioning` | Read THEN Skill |
| d | `promote-hormozi` | Skill |
| e | `promote-schwartz` | Skill |
| f | `promote-ammar` | Skill |
| g | `promote-growth-four-fits` | Skill |
| h | `promote-plg-design` | Skill (conditional: software products only) |
| i | `../../../references/psychology-canon.md` | Read |
| j | `promote-x-mastery` | Skill |
| k | `promote-mrbeast` | Skill (conditional: video channel retained) |
| l | `promote-geo-optimization` | Skill |
| m | `../../../references/demand-gen.md` + `../../../references/attribution-canon.md` THEN `promote-paul-graham` | Read THEN Skill |
| n | `promote-holiday` | Skill |
| o | `../../../references/strategy-kernel.md` | Read (validator AVAL) |

For each Skill step:
1. Build the invocation prompt per `delegation-matrix.md`.
2. Inject relevant context (from upstream artifacts and STATE.known_facts).
3. Invoke the skill.
4. Capture the output and write to the prescribed artifact path.
5. **Quality gate**: artifact exists, follows expected schema (cf. `strategy-schema.md`), contains no `Pattern #11` (auto-explanatory extensions — see `../../../references/skill-grammar.md` Part 5).
6. If quality gate fails, retry once with refined input. If fails again, escalate (mark `manual_review_needed` in STATE).

For each Read step:
1. Open the reference file.
2. Apply its content as a mental gate (Rumelt) or input modulator (psychology-canon).

**Caching rule**: each artifact is generated **once per campaign** unless explicit re-invocation needed. If `STATE.phase == P3-resume`, only re-run delegations where input artifacts have changed.

**Time budget**: 15 delegations × ~30K tokens each = ~450K tokens for P3. Budget breach signal: if delegation cost exceeds 50K tokens, log and continue (don't abort).

## P4 — CONTENT PRODUCTION 14-DAY (NEW v1.1.0)

For the **first 14 days** of the calendar (J0-J13), produce concrete posts using operator skills in PRODUCTION mode.

**Steps**:

1. **Build calendar skeleton** : 90 days × cadence per channel. For J14-J89, status='outline' with hypothesis. For J0-J13, prepare for production.
2. **For each J0-J13 slot** (~14-42 slots depending on cadence) :
   - Read slot row (date, channel, pillar, format, hypothesis).
   - Read `strategy/operator-consultations/{operator-name}.md` for the channel's operator (created in P3.C). **CRITICAL** : without this, abort and require P3.C to be re-run.
   - Identify operator/framework via routing table in `../../../references/content-production.md`.
   - If operator skill: invoke in PRODUCTION mode with the 7 inputs (positioning + pillar + cadence + voice + slot.hypothesis + strategic_recommendations + anti_patterns).
   - If framework: read framework + apply tactiques + generate.
   - Save post to `campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md` (template: `templates/post.md.template`).
   - Update calendar row: status='concrete', body_path, generated_at.
3. **Quality gates** per `../../../references/content-production.md` : title length 30-80 chars, body word-count appropriate, voice match (informal cover-the-name), no Pattern #11, single CTA, asset specs explicit.
4. **If quality gate fails** : retry once with refined input. If fails again: mark `manual_review_needed` for that slot, continue.
5. **Output** : 14-42 concrete posts in `campaigns/{slug}/content/posts/` + calendar updates.

**Time budget** : ~30-50K tokens for content production 14d (cf. plan trade-offs Phase 7.J).

**For J14-J89 (76 days remaining)** : NOT produced in P4. They are converted on demand by `promote-content-batcher` at user invocation (J+14, J+28, J+42, etc.).

## P5 — PACKAGING (renamed from P4 in v1.0.0)

**Steps**:

1. Generate `strategy/00-product-brief.md` from intake/* artifacts (template: `templates/00-product-brief.md.template`).
2. Generate `strategy/01-market-research.md` from research/* artifacts.
3. P3 artifacts (02-10) are already in place from P3.A-G.
4. Calendar `strategy/11-content-calendar-90d.csv` already filled with J0-J13 concrete (from P4) + J14-J89 outline. Columns: date, channel, pillar, format, title, body_outline, body_path, assets_path, status.
5. Generate `strategy/strategy-summary.md` (2-page exec summary, template). Must contain Rumelt's 3 elements + tradeoffs résolus from P3.D.
6. Generate `strategy/handoff-to-executor.yaml` with sections including content (concrete_posts_count, outlines_count, posts_directory, channel_distribution).
7. Run `completeness-checklist.md` (40 points).
8. **Decision** :
   - `pass% >= 90%` → `STATE.status = ready-for-executor`.
   - `90% > pass% >= 70%` → loop back to weakest phase, retry once.
   - `pass% < 70%` → escalate.
9. Output completion summary to user with paths to `strategy-summary.md` + `content/posts/` directory.

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
