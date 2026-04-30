# Content Production — factorisation logique multi-canal (v1.3.0)

> **Rôle dans le projet** : référence consultée par `promote-strategist` (P4 Content Production 14-day) ET par `promote-content-batcher` (conversion outlines → concrets après J+14). Garantit que les deux skills produisent du contenu de manière cohérente, en consommant les `strategic_recommendations` des operators établies en P3.C ET le `verified-claims.csv` validé en P1.5.

## v1.3.0 — Changements vs v1.2.0

- **Output schema split** : chaque post produit = 2 fichiers. `.md` = pur contenu prêt à copier-coller. `.meta.yaml` (sous `content/posts/.meta/`) = metadata complète (asset specs, posting metadata, quality gate audits, voice notes, factual_claims_used, narrative_gaps_to_fill).
- **Quality Gate #7 — Factual Claims Check** : nouveau gate cross-checke chaque claim du post contre `intake/verified-claims.csv` + `intake/never-claims.txt`. Reject si fabrication détectée.
- **Quality Gate #8 — Reader-Honesty** : nouveau gate vérifie ratio lecteur-first vs auteur-first (cible 70/30).
- **Quality Gate #1 (form) durci** : reject hard si le `.md` body contient encore un `{...}` placeholder.
- **Atomization variants** : la grille pillar n'est plus reproduite à l'identique. 5 variants imposés par rotation.

## Pourquoi ce framework existe

Sans factorisation, P4 du strategist et content-batcher dupliqueraient leur logique de production. Cette référence centralise **comment produire un post concret** pour chaque canal, en consommant les artefacts strategist (pillars + cadence + voice + operator consultations + verified-claims).

## Inputs requis pour produire un post

Pour CHAQUE slot du calendar à concrétiser, les inputs nécessaires :

1. **STATE.yaml** de la campagne (campaign_id, runtime_root, mode).
2. **strategy/00-product-brief.md** (one-liner, JTBD, voice).
3. **strategy/03-positioning.md** (Dunford one-sentence + contrarian angle Ammar).
4. **strategy/04-offer-audit.md** (awareness stage Schwartz, mass desire, leviers Cialdini).
5. **strategy/07-content-pillars.md** (pillar du slot + framework copy + audience awareness target).
6. **strategy/08-channel-strategy.md** (cadence + voice + format pour le canal).
7. **strategy/operator-consultations/{operator-name}.md** (les `strategic_recommendations` + `narrative_hypotheses` + `anti_patterns` de l'operator pour ce produit). **CRITIQUE**.
8. **intake/verified-claims.csv** (le ledger des claims factuels validés par le user). **CRITIQUE v1.3.0** — sans lui, le subagent invente.
9. **intake/never-claims.txt** (les zones interdites définies par le user).
10. Slot row du calendar : date, channel, pillar, format, awareness_stage, hypothesis (titre court d'orientation).

## Logique de production par slot (v1.3.0)

```
1. Read all 10 inputs above for this slot.
2. Identify operator-prompt-path or framework-path from routing table below.
3. If operator/persona prompt (under prompts/...):
   3.a. Read the prompt.md file content (operator's voice + frameworks + signature moves
        + anti-fabrication contract by reference).
   3.b. Spawn a Task subagent with prompt = (operator content) + (slot context with all 10 inputs)
        + production-mode instruction.
   3.c. Subagent returns: title + body + factual_claims_used + narrative_gaps_to_fill
        + assets_specs + posting_metadata.
4. Else if framework reference (under references/...):
   4.a. Read the framework markdown.
   4.b. Apply tactiques + cadence + format for this slot directly (no subagent — strategist
        generates inline). Strategist STILL applies anti-fabrication contract on factual claims.
   4.c. Output: title + body + factual_claims_used + assets_specs.
5. Run Quality Gates #1-#8 (see below) on the draft.
6. If pass: split into 2 files
   - campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md (PURE CONTENT)
   - campaigns/{slug}/content/posts/.meta/{YYYY-MM-DD}-{channel}-{pillar-short}.yaml (METADATA)
7. Update calendar row : status='concrete', body_path, meta_path, generated_at.
```

**Pattern Read+Task verbatim** (utilisé par P3.C strategic consultations + P4 production + content-batcher) :

```
operator_path = "prompts/operators/welsh-linkedin/prompt.md"  # from routing table
operator_content = Read(operator_path)
verified_claims = Read("campaigns/{slug}/intake/verified-claims.csv")
never_claims = Read("campaigns/{slug}/intake/never-claims.txt")
context = {
  "product_brief": "...", "icp": "...", "jtbd": "...", "positioning": "...",
  "awareness_stage": "...", "goal": "...", "constraints": "...",
  "slot_hypothesis": "...", "pillar": "...", "cadence": "...", "voice": "...",
  "strategic_recommendations": "...",  # from prior consultation if production mode
  "narrative_hypotheses": "...",       # NEW v1.3 — hypotheses requiring user confirmation
  "verified_claims_csv": verified_claims,  # NEW v1.3
  "never_claims_txt": never_claims,        # NEW v1.3
}

Task(
  subagent_type="general-purpose",
  description="<operator-name> <consultation|production> mode",
  prompt=f"""
You are this operator. Use the voice, frameworks, and signature moves below:

---
{operator_content}
---

You operate under the project-wide anti-fabrication contract documented in
references/anti-fabrication-contract.md. The contract is binding. See your operator
prompt for the included reference. Specifically: any factual claim about product/author/
process must trace to verified-claims.csv (claim_id), be a public verifiable fact, or
be explicitly attributed. If you need a fact you don't have, list it under
narrative_gaps_to_fill — never fabricate.

Now run a {consultation|production} on this campaign context:

{json.dumps(context, indent=2)}

Return structured output:
{schema for consultation OR schema for production post — see anti-fabrication-contract.md}
"""
)
```

**Critical** : le subagent reçoit le `prompt.md` complet de l'operator (donc adopte sa voice + frameworks + anti-patterns + anti-fabrication contract) ET le contexte stratégique ET le ledger. C'est ce qui transforme un LLM générique en operator-incarné fonctionnel ET factuellement contraint.

## Channel → Operator/Framework routing table (v1.3.0 paths)

Inchangé vs v1.2.0 — toujours via `prompts/{operators,personas,frameworks,...}/{name}/prompt.md` lus en Read+Task.

### Organic channels

| Channel | Prompt path (Read + Task) | Type |
|---|---|---|
| X / Twitter (organic) | `prompts/personas/x-mastery/prompt.md` | Persona-incarnée |
| LinkedIn (organic) | `prompts/operators/welsh-linkedin/prompt.md` | Operator |
| Newsletter / Email (volume + paid acq) | `prompts/operators/mcgarry-newsletter/prompt.md` | Operator |
| Substack premium / paid sub | `prompts/operators/lenny-substack/prompt.md` | Operator |
| Founder-led cross-channel | `prompts/personas/gerhardt-founder/prompt.md` | Persona |
| YouTube long-form | `prompts/personas/mrbeast/prompt.md` | Persona-incarnée |
| TikTok / Reels / Shorts (organic) | `prompts/operators/hormozi-shortform/prompt.md` | Operator |
| Instagram organic (Feed/Stories/Carousels) | `prompts/operators/johnson-instagram/prompt.md` | Operator |
| Discord / Slack / community | `prompts/operators/isenberg-community/prompt.md` | Operator |
| Podcast (host + guest strategy) | `prompts/operators/ferriss-podcast/prompt.md` | Operator |
| Cold/Warm B2B Outbound | `prompts/operators/robinson-outbound/prompt.md` | Operator |
| SEO / GEO content | `prompts/operators/indig-geo-seo/prompt.md` | Operator |
| Reddit organic | `references/channel-reddit.md` | Framework (read directly) |
| HN + Product Hunt + Indie Hackers launches | `references/channel-hn-and-launches.md` | Framework |
| Facebook organic | `references/channel-facebook.md` | Framework |
| Pinterest organic | `references/channel-pinterest-organic.md` | Framework |
| Threads/Bluesky/Mastodon/WhatsApp/Telegram | `references/channel-emerging-platforms-2026.md` | Framework |

### Paid channels

| Channel | Prompt path | Type |
|---|---|---|
| Meta Ads (FB + IG paid) | `prompts/operators/faris-meta-and-fundamentals/prompt.md` | Operator |
| Google PMax + Shopping | `prompts/operators/ryan-pmax/prompt.md` | Operator |
| Google Search + PPC | `prompts/operators/vallaeys-google/prompt.md` | Operator |
| LinkedIn Ads | `prompts/operators/wilcox-linkedin-ads/prompt.md` | Operator |
| TikTok Ads + Snapchat | `prompts/operators/sanchez-tiktok/prompt.md` | Operator |
| Amazon Ads + YouTube Ads | `prompts/operators/curry-amazon-youtube/prompt.md` | Operator |
| Mobile UA / iOS14 attribution | `prompts/operators/seufert-mobile-attribution/prompt.md` | Operator (consultation focus) |
| X / Reddit / Pinterest paid | `references/channel-paid-x-reddit-pinterest.md` | Framework |
| CTV / Retail Media / TikTok Shop / DOOH | `references/channel-paid-emerging-2026.md` | Framework |
| Affiliate / B2B sponsorships / Podcast Ads / Email Ads | `references/channel-paid-other-niches.md` | Framework |

### Foundations (P3.A, used by strategist directly)

| Function | Prompt path | Type |
|---|---|---|
| Offer audit (Hormozi) | `prompts/personas/hormozi/prompt.md` | Persona-incarnée |
| Awareness stages (Schwartz) | `prompts/personas/schwartz/prompt.md` | Persona-incarnée |
| Contrarian reframe (Ammar) | `prompts/personas/ammar/prompt.md` | Persona-incarnée |
| Distribution philosophy (PG) | `prompts/personas/paul-graham/prompt.md` | Persona-incarnée |
| Vision/product clarity (Steve Jobs) | `prompts/personas/steve-jobs/prompt.md` | Persona-incarnée |
| Earned media + perennial (Holiday) | `prompts/personas/holiday/prompt.md` | Persona-incarnée |
| Cialdini levers | `prompts/frameworks/cialdini/prompt.md` | Framework |
| Voss negotiation | `prompts/frameworks/voss/prompt.md` | Framework |
| Dunford positioning | `prompts/frameworks/dunford-positioning/prompt.md` | Framework |
| JTBD-Switch | `prompts/frameworks/jtbd-switch/prompt.md` | Framework |
| Growth Four-Fits | `prompts/frameworks/growth-four-fits/prompt.md` | Framework |
| PLG-Design | `prompts/frameworks/plg-design/prompt.md` | Framework |
| GEO-Optimization | `prompts/frameworks/geo-optimization/prompt.md` | Framework |
| AI-Content-Pipeline | `prompts/frameworks/ai-content-pipeline/prompt.md` | Framework |
| Customer research | `prompts/tactical/customer-research/prompt.md` | Tactical |
| Pricing strategy | `prompts/tactical/pricing-strategy/prompt.md` | Tactical |
| Channel-strategist (orchestrator) | `prompts/orchestrators/channel-strategist/prompt.md` | Orchestrator |

## Output schema v1.3.0 — 2 fichiers par post

### Fichier 1 : `content/posts/{YYYY-MM-DD}-{channel}-{pillar-short}.md`

**PUR CONTENU PRÊT À COPIER-COLLER**. Aucune metadata d'orchestration, aucune voice note, aucune quality gate audit. Le user ouvre, copie le body, colle dans LinkedIn/Substack/etc.

```markdown
---
date: 2026-04-30
channel: linkedin
pillar: 1-meta-ia-ecrit
format: long-form
awareness_stage: problem-aware
---

{Le body du post — copier-coller direct vers la plateforme. Pas de sections "Hypothesis from calendar", pas de "Operator notes", pas de placeholders {...}.}

{Si le canal le justifie (LinkedIn long-form, X thread reply), section ajoutée :}

---
*First comment to post :*

{Texte du premier commentaire à poster séparément après publication. Pas de metadata.}
```

**Reject-on-placeholder rule** : si le body contient encore `{...}` à la livraison "concrete", Quality Gate #1 (form) FAIL. Le post sort en `manual_review_needed` avec note explicite. JAMAIS de `.md` "concrete" avec template à trous.

### Fichier 2 : `content/posts/.meta/{YYYY-MM-DD}-{channel}-{pillar-short}.yaml`

Toute la metadata. Lisible pour audit, pour analytics, pour `promote-executor`. Pas affiché au user en lecture quotidienne.

```yaml
post_id: 2026-04-30-linkedin-pillar1-salvage
slug: 2026-04-30-linkedin-pillar1-salvage

# Production trace
generated_at: 2026-04-30T14:32:00Z
operator_used: prompts/operators/welsh-linkedin/prompt.md
operator_mode: production
production_subagent_id: <task-id-if-applicable>
generated_by_phase: P4  # or P4-batcher if produced by content-batcher

# Strategy linkage
campaign_slug: amazon-fr-dp-b0gx2zpnyq
slot_hypothesis: "Test contrarian POV reframe sur méta-IA-écrit"
pillar_full_name: "Méta-IA-écrit (le livre est lui-même fait avec l'IA)"
schwartz_awareness_stage: problem-aware
content_format_taxonomy: long-form-narrative
atomization_variant_used: failure-confession  # one of: hook-shock | dimanche-doute | corbeille | contrast-reader | failure-confession | objection-killer | sub-frame-zoom | case-micro | contrarian-reverse | micro-anecdote

# Asset specs (briefed, not generated)
asset_specs:
  image_brief: |
    Type : carrousel 4 slides
    Slide 1 : titre "Les 3 filtres", police bold sans-serif
    ...
  alt_text: "Carrousel 4 slides illustrant les 3 filtres décisionnels"
  designer_notes: |
    ...

# Posting metadata (for promote-executor in Part 2)
posting_metadata:
  best_time_iso: 2026-04-30T08:00:00+02:00
  best_time_human: "Mardi 30 avril 8h CET"
  hashtags: [#IAauboulot, #DirigeantPME, #IntegrationIA]
  cta_target_url: "https://substack.com/.../le-post-it-jaune"
  cta_text_in_body: "Lien en commentaire."
  cross_post: null
  utm_params: "utm_source=linkedin&utm_medium=organic&utm_campaign=launch-w1"

# Quality gate audit (full trace)
quality_gates:
  gate_1_form:
    pass: true
    title_chars: 47
    body_words: 312
    placeholders_found: 0
  gate_2_word_count:
    pass: true
    target_range: [200, 500]
  gate_3_voice_match:
    pass: true
    cover_the_name_score: 8/10
  gate_4_anti_patterns:
    pass: true
    patterns_checked: [pattern-11, generic-llm-voice, hashtag-spam, multiple-cta]
    violations: []
  gate_5_single_cta:
    pass: true
    cta_count: 1
  gate_6_asset_specs:
    pass: true
    asset_count: 1
  gate_7_factual_claims_check:
    pass: true
    reject_immediate: false  # never-claim match
    factual_claims_traced:
      - claim_in_post: "Le livre contient 15 cas et 3 filtres"
        source: claim_id_C001
      - claim_in_post: "Écrit avec l'IA depuis le départ"
        source: claim_id_C002
      - claim_in_post: "AI Act art. 4 actif 2 août 2026"
        source: public_fact
    unverified_claims: []
  gate_8_reader_honesty:
    pass: true
    ratio_reader_first_pct: 78
    ratio_author_first_pct: 22
    threshold: 70/30
    judge_notes: "Post sert le lecteur via les 3 filtres opérationnels. CTA discret en fin."

# Anti-fabrication trace
factual_claims_used:
  - claim_id: C001
    where_in_post: "first paragraph"
  - claim_id: C002
    where_in_post: "third paragraph"
  - public_fact: "AI Act art. 4 entry-into-force 2026-08-02"
    where_in_post: "section 'compte à rebours'"
  - attributed: null  # no attributed claims used

narrative_gaps_to_fill: []  # empty — post produced concrete-ready

# Operator notes
operator_notes:
  signature_moves_used: ["Welsh failure-confession opening", "210-char hook test"]
  anti_patterns_avoided: ["pattern-11", "atomization-mechanical-repeat"]
  voice_fingerprint_score: 8.2/10
  variations_from_default: |
    Used failure-confession variant of atomization (rotation rule — previous was case-micro).

# Production cost
tokens_used:
  input: 9430
  output: 2850
  total: 12280
```

## Quality gates avant marking 'concrete' (8 gates v1.3.0)

Pour chaque post produit, exécuter dans cet ordre. Si un gate fail, retry une fois avec inputs enrichis. Si fail à nouveau : marquer `manual_review_needed` et continuer.

### Gate #1 — Form check

- Title length ≤ 80 chars (LinkedIn ne montre pas title mais utile pour archive).
- Body word-count dans la fourchette du format (varie : email 500-1200 ; thread X 500-2000 ; carrousel LinkedIn 200-500 ; long-form blog 800-2500).
- **Reject-on-placeholder** : si le body `.md` contient `{...}`, FAIL hard, pas de retry. Force le user à fill manuellement OU à laisser le slot en outline.

### Gate #2 — Word count précis

- Détaillé par format (cf. Gate #1).

### Gate #3 — Voice match (cover-the-name test informel)

- Le post sonne comme la voice définie en `08-channel-strategy.md` ?

### Gate #4 — Anti-patterns transverses

- Pattern #11 (Explanatory Extension) — cf. `skill-grammar.md`.
- Generic LLM voice (sans operator/framework, le post sonne wikipedia GPT).
- Cross-channel copy-paste sans adaptation.
- Hashtag spam (5 hashtags niche > 30 spam, sauf Pinterest).
- **Atomization-mechanical-repeat** : si ce post est un atom d'un pillar déjà publié, vérifier que la structure ne reproduit pas le précédent à l'identique. Cf. atomization-variants library ci-dessous.

### Gate #5 — Single CTA

- Un (et un seul) call-to-action clair en fin de post. Multiple CTA = fail.

### Gate #6 — Asset specs

- Briefés (pas générés), avec assez de détail qu'un designer puisse exécuter.

### Gate #7 — Factual Claims Check (NEW v1.3.0)

Subagent `prompts/utility/fact-checker/prompt.md` :

```
INPUT: post draft (title + body) + verified-claims.csv + never-claims.txt + url-crawl.md
PROCESSING:
1. Extract every factual claim from post (statement on product/author/process/numbers).
2. For each claim:
   a. Match never-claims (semantic) → reject_immediate if match
   b. Match verified-claims (claim_id + variations) → OK, log claim_id
   c. Match Public Verifiable (cite-able dated/numeric facts) → OK, log "public_fact"
   d. Match Attributed (markers "FN raconte que...", "selon l'auteur...") → OK, log "attributed"
   e. Else → UNVERIFIED, log claim_text + location
3. If reject_immediate OR unverified_count > 2 → fail.
   If 1 ≤ unverified_count ≤ 2 → soft-fail (retry once with explicit ledger constraints).
   If unverified_count == 0 AND no reject_immediate → pass.

OUTPUT: yaml gate_7_factual_claims_check field for .meta.yaml + recommendation
        (ship | retry_with_ledger_constraints | manual_review_needed).
```

Coût : ~3-7K tokens par post. Net-positif vs économies trim P3.

### Gate #8 — Reader-Honesty (NEW v1.3.0)

Subagent `prompts/utility/reader-honesty-judge/prompt.md` :

```
INPUT: post draft (body) + product context (00-product-brief.md résumé) + awareness_stage.
PROCESSING:
1. Decompose body in N segments (paragraphs or beats).
2. For each segment, classify intent:
   - reader-first: gives information, perspective, utility, entertainment
   - author-first: builds credibility, name-drops, lists achievements, hard-sells
3. Compute ratio reader-first / total.
4. Threshold: ratio_reader_first ≥ 70%. Auto-promo > 50% = fail.

OUTPUT: yaml gate_8_reader_honesty field + recommendation (ship | retry_more_reader_first).
```

Coût : ~2-4K tokens par post.

## Atomization variants library (NEW v1.3.0)

Quand un pillar long-form a été posté, ses 3-4 atomizations qui suivent ne peuvent PAS reproduire la même structure. Chaque atom = 1 variant distinct, rotation forcée.

### 10 variants disponibles

1. **hook-shock** : *"X chiffre/stat. Y conséquence."* (specific number opening)
2. **dimanche-doute** : moment de doute privé qui ouvre, résolu par le pillar
3. **corbeille** : *"J'ai jeté X. Voilà pourquoi."* (decision/elimination angle)
4. **contrast-reader** : *"On me dit X. Mais regardez Y."*
5. **failure-confession** : *"J'ai cru que X. C'était faux. Voici pourquoi."*
6. **objection-killer** : *"Vous me dites Y. Voici la réponse."*
7. **sub-frame-zoom** : zoom sur 1 des 3 axes du pillar seul (vs les 3 ensemble)
8. **case-micro** : 1 cas client en 200 mots, structurellement pas un case-study (juste un fragment vivant)
9. **contrarian-reverse** : *"Vous attendiez Z. Mais en réalité, le contraire."*
10. **micro-anecdote-from-pillar** : extraction d'un détail ou anecdote du pillar long-form, raconté en standalone

### Règle de rotation

Pour le pillar P, si atom-1 a utilisé variant V1 :
- atom-2 doit utiliser un variant V2 ≠ V1
- atom-3 doit utiliser V3 ≠ V1, V2
- atom-4 V4 ≠ V1, V2, V3

L'operator (en mode production) reçoit dans son contexte slot l'historique des variants utilisés pour ce pillar. Il choisit explicitement et marque `atomization_variant_used` dans le `.meta.yaml`.

Quality Gate #4 (anti-pattern) check ce champ : si même variant que les 3 atoms précédents → fail (atomization-mechanical-repeat).

## Anti-patterns transverses (à éviter quel que soit le canal)

- **Pattern #11 (Explanatory Extension)** — cf. `./skill-grammar.md` Partie 5.
- **Generic LLM voice** — sans operator/framework, post = wikipedia GPT.
- **Cross-channel copy-paste sans adaptation**.
- **CTA absent ou multiple** — un seul, clair, en fin.
- **Hypothesis ignorée** — le slot a une hypothesis ; le post doit l'opérationnaliser.
- **Hashtag spam** — 5 hashtags niche > 30 spam (sauf Pinterest).
- **Atomization-mechanical-repeat** — variant non rotaté.
- **Process fabrication** — claim factuelle non sourcée. Voir Gate #7 + `references/anti-fabrication-contract.md`.
- **Auto-promotion masquée** — > 50% body sert l'auteur. Voir Gate #8.
- **Placeholder unfilled** — `{...}` dans le `.md`. Voir Gate #1 reject-on-placeholder.

## Coût en tokens estimé par post (v1.3.0)

- Operator (avec 10 inputs incl. ledger) : 6-12K input + 2-3K output = 8-15K total.
- Framework reference : 4-8K input + 1-2K output = 5-10K total.
- Quality Gate #7 (fact-checker) : 3-7K total.
- Quality Gate #8 (reader-honesty) : 2-4K total.

Pour 14 jours × cadence ~3 posts/jour = ~42 posts × ~12K tokens en moyenne = ~500K tokens pour P4 production. Compensé par les économies Phase 9.E (cut Geo-Plan + Rumelt-Aval + trim Instrumentation/Calendar = -105K tokens en P3).

**Bilan v1.3.0** : tokens totaux campagne ~1.2-1.3M (vs 1.51M v1.2.0), soit 15-20% de réduction à qualité supérieure.

## Changelog

- **0.2.0** (2026-04-30) — v1.3.0. Output schema split (.md pure content + .meta/.yaml metadata). Quality Gate #7 (factual claims check) + #8 (reader-honesty). Atomization variants library (10 variants, rotation forcée). Reject-on-placeholder rule. Inputs enrichis (verified-claims.csv + never-claims.txt mandatory).
- **0.1.0** (2026-04-29) — v1.1.0. Factorisation P4 strategist + content-batcher logic.
