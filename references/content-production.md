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

## Logique de production par slot

```
1. Read all 7 inputs above for this slot.
2. Identify operator-of-channel (cf. table below).
3. If operator skill exists in skills/promote-{operator}/:
   3.a. Invoke operator in MODE PRODUCTION (not consultation — that was P3.C).
   3.b. Pass: pillar + cadence + voice + slot.hypothesis + strategic_recommendations + anti_patterns.
   3.c. Operator returns: title + body + assets_specs + posting_metadata.
4. Else if framework reference exists in references/channel-{name}.md:
   4.a. Read the framework.
   4.b. Apply tactiques + cadence + format for this slot.
   4.c. Strategist (or content-batcher) generates title + body + assets_specs.
5. Save to campaigns/{slug}/content/posts/{YYYY-MM-DD}-{channel}-{pillar}.md (cf. templates/post.md.template).
6. Update calendar row : status='concrete', body_path=<path>, generated_at=<ISO date>.
```

## Channel → Operator/Framework routing table

| Channel | Routing | Type |
|---|---|---|
| X / Twitter (organic) | `promote-x-mastery` | Operator |
| LinkedIn (organic) | `promote-welsh-linkedin` | Operator |
| Newsletter / Email (volume + paid acq) | `promote-mcgarry-newsletter` | Operator |
| Substack premium / paid sub | `promote-lenny-substack` | Operator |
| Founder-led cross-channel | `promote-gerhardt-founder` | Operator |
| YouTube long-form | `promote-mrbeast` | Operator |
| TikTok / Reels / Shorts (organic) | `promote-hormozi-shortform` | Operator |
| Instagram organic (Feed/Stories/Carousels) | `promote-johnson-instagram` | Operator |
| Discord / Slack / community | `promote-isenberg-community` | Operator |
| Podcast (host + guest strategy) | `promote-ferriss-podcast` | Operator |
| Cold/Warm B2B Outbound | `promote-robinson-outbound` | Operator |
| SEO / GEO content | `promote-indig-geo-seo` | Operator |
| Reddit organic | `references/channel-reddit.md` | Framework |
| HN + Product Hunt + Indie Hackers launches | `references/channel-hn-and-launches.md` | Framework |
| Facebook organic | `references/channel-facebook.md` | Framework |
| Pinterest organic | `references/channel-pinterest-organic.md` | Framework |
| Threads/Bluesky/Mastodon/WhatsApp/Telegram | `references/channel-emerging-platforms-2026.md` | Framework |
| Meta Ads (FB + IG paid) | `promote-faris-meta-and-fundamentals` | Operator |
| Google PMax + Shopping | `promote-ryan-pmax` | Operator |
| Google Search + PPC | `promote-vallaeys-google` | Operator |
| LinkedIn Ads | `promote-wilcox-linkedin-ads` | Operator |
| TikTok Ads + Snapchat | `promote-sanchez-tiktok` | Operator |
| Amazon Ads + YouTube Ads | `promote-curry-amazon-youtube` | Operator |
| Mobile UA / iOS14 attribution | `promote-seufert-mobile-attribution` | Operator (consultation focus) |
| X / Reddit / Pinterest paid | `references/channel-paid-x-reddit-pinterest.md` | Framework |
| CTV / Retail Media / TikTok Shop / DOOH | `references/channel-paid-emerging-2026.md` | Framework |
| Affiliate / B2B sponsorships / Podcast Ads / Email Ads | `references/channel-paid-other-niches.md` | Framework |

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
