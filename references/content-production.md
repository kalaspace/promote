# Content Production — factorisation logique multi-canal

> **Rôle dans le projet** : référence consultée par `promote-strategist` (P4 Content Production 14-day) ET par `promote-content-batcher` (conversion outlines → concrets après J+14). Garantit que les deux skills produisent du contenu de manière cohérente, en consommant les `strategic_recommendations` des operators établies en P3.C.

## Pourquoi ce framework existe

Sans factorisation, P4 du strategist et content-batcher dupliqueraient leur logique de production. Cette référence centralise **comment produire un post concret** pour chaque canal, en consommant les artefacts strategist (pillars + cadence + voice + operator consultations).

## Inputs requis pour produire un post

Pour CHAQUE slot du calendar à concrétiser (que ce soit en P4 ou via content-batcher), les inputs nécessaires :

1. **STATE.yaml** de la campagne (campaign_id, runtime_root, mode).
2. **strategy/00-product-brief.md** (one-liner, JTBD, voice).
3. **strategy/03-positioning.md** (Dunford one-sentence + contrarian angle Ammar).
4. **strategy/04-offer-audit.md** (awareness stage Schwartz, mass desire, leviers Cialdini).
5. **strategy/07-content-pillars.md** (pillar du slot + framework copy + audience awareness target).
6. **strategy/08-channel-strategy.md** (cadence + voice + format pour le canal).
7. **strategy/operator-consultations/{operator-name}.md** (les `strategic_recommendations` de l'operator du canal pour ce produit). **CRITIQUE** : sans ce fichier, on génère du contenu générique qui ignore l'expertise de l'operator.
8. Slot row du calendar : date, channel, pillar, format, hypothesis (titre court d'orientation).

## Logique de production par slot (v1.2.0)

```
1. Read all 7 inputs above for this slot.
2. Identify operator-prompt-path or framework-path from routing table below.
3. If operator/persona prompt (under prompts/...):
   3.a. Read the prompt.md file content (operator's voice + frameworks + signature moves).
   3.b. Spawn a Task subagent with prompt = (operator content) + (slot context with all 7 inputs) + production-mode instruction.
   3.c. Subagent returns: title + body + assets_specs + posting_metadata.
4. Else if framework reference (under references/...):
   4.a. Read the framework markdown.
   4.b. Apply tactiques + cadence + format for this slot directly (no subagent — strategist generates inline).
   4.c. Output: title + body + assets_specs.
5. Save to campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar}.md (cf. templates/post.md.template).
6. Update calendar row : status='concrete', body_path=<path>, generated_at=<ISO date>.
```

**Pattern Read+Task verbatim** (utilisé par P3.C strategic consultations + P4 production + content-batcher) :

```
operator_path = "prompts/operators/welsh-linkedin/prompt.md"  # from routing table
operator_content = Read(operator_path)
context = {
  "product_brief": "...", "icp": "...", "jtbd": "...", "positioning": "...",
  "awareness_stage": "...", "goal": "...", "constraints": "...",
  "slot_hypothesis": "...", "pillar": "...", "cadence": "...", "voice": "...",
  "strategic_recommendations": "...",  # from prior consultation if production mode
}

Task(
  subagent_type="general-purpose",
  description="<operator-name> <consultation|production> mode",
  prompt=f"""
You are this operator. Use the voice, frameworks, and signature moves below:

---
{operator_content}
---

Now run a {consultation|production} on this campaign context:

{json.dumps(context, indent=2)}

Return structured output:
{schema for consultation OR schema for production post}
"""
)
```

**Critical** : le subagent reçoit le `prompt.md` complet de l'operator (donc adopte sa voice + frameworks + anti-patterns) ET le contexte stratégique. C'est ce qui transforme un LLM générique en operator-incarné fonctionnel.

## Channel → Operator/Framework routing table (v1.2.0 paths)

**v1.2.0 BREAKING change** : les "operator skills" sont maintenant des **prompts internes** (non-skills) sous `prompts/`, lus via Read+Task tool au lieu de cascade `/skill:name`. Chaque routing pointe vers le `prompt.md` du sous-dossier correspondant.

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

## Format du post produit (template `templates/post.md.template`)

```markdown
---
slug: {YYYY-MM-DD}-{channel}-{pillar-short}
date: {YYYY-MM-DD}
channel: {channel}
pillar: {pillar-name}
format: {long-form | thread | carousel | reel | short | email | etc.}
operator_or_framework: {promote-X or references/channel-X.md}
generated_at: {ISO date}
status: draft  # draft → approved → posted
---

# {Title (30-80 chars, hook)}

## Hypothesis (from strategist calendar)
{the original slot.hypothesis}

## Body
{Full content : 200-1500 mots selon canal/format}

## Assets needed (briefs, not generated)
- {asset 1 brief}
- {asset 2 brief}

## Posting metadata
- Best time : {YYYY-MM-DD HH:MM TZ}
- Hashtags : {if applicable}
- CTA : {explicit call-to-action}
- Cross-post : {if multi-channel}
- Tracking UTM : {if applicable}

## Operator notes (if applicable)
{Anti-patterns invoqués, signature moves utilisés, deviations from default}
```

## Quality gates avant marking 'concrete'

Pour chaque post produit :

1. **Title** ≤ 80 chars, hook structurellement clair.
2. **Body** dans la fourchette word-count du format (varie : email 500-1200 ; thread X 500-2000 ; carrousel LinkedIn 200-500 caps + visuel ; long-form blog 800-2500).
3. **Voice match** : le post sonne comme la voice définie en `08-channel-strategy.md` ? (Cover-the-Name test informel.)
4. **Anti-patterns** : aucun des anti-patterns de l'operator/framework triggered (Pattern #11 explanatory extension, etc.).
5. **CTA** : un (et un seul) call-to-action clair en fin de post.
6. **Assets specs** : briefés (pas générés), avec assez de détail pour qu'un designer puisse exécuter.

Si une quality gate échoue : retry une fois (avec input enrichi). Si fail à nouveau : marquer `manual_review_needed` et continuer.

## Anti-patterns transverses (à éviter quel que soit le canal)

- **Pattern #11 (Explanatory Extension)** — cf. `./skill-grammar.md` Partie 5. Le LLM auto-explique chaque claim. Anti-pattern endémique.
- **Generic LLM voice** — sans operator/framework, le post sonne comme un wikipedia GPT. Toujours appliquer la voice de l'operator/framework.
- **Cross-channel copy-paste sans adaptation** — le même body sur X et LinkedIn = waste. Adapter format + voice + cadence.
- **CTA absent ou multiple** — un seul CTA, clair, en fin.
- **Hypothesis ignorée** — le slot du calendar a une hypothesis (ex: "test contrarian POV reframe"). Le post produit doit l'opérationnaliser, pas s'en éloigner.
- **Hashtag spam** — 5 hashtags niche > 30 spam (sauf Pinterest où l'inverse).

## Coût en tokens estimé par post

- Operator skill (avec 7 inputs) : 5-10K tokens d'input + 1-3K output = 6-13K total.
- Framework reference : 3-6K input + 1-2K output = 4-8K total.

Pour 14 jours × cadence 3 posts/jour = 42 posts × 8K tokens en moyenne = ~340K tokens pour P4 Content Production. Budget acceptable (cf. plan trade-offs).

## Changelog

- 0.1.0 (2026-04-29) — Initial release. Factorisation P4 strategist + content-batcher logic.
