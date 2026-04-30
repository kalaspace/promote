# Attribution — promote-seufert-mobile-attribution

**Persona distillée** : Eric Seufert (founder Mobile Dev Memo + Heracles Capital, author Freemium Economics)
**Source primaire** : mobiledevmemo.com (essays, paywalled + free)
**Date de distillation** : 2026-04-28
**Auteur de la distillation** : François Neumann
**Méthodologie** : huashu-nuwa (女娲造人) appliqué à l'analyste-investisseur de référence du mobile UA + post-iOS14 attribution 2024-2026

## Description

Distillation locale de la pensée et de la voix opérationnelle d'Eric Seufert — l'analyste-investisseur-strategist mondial de référence pour le mobile UA et l'attribution post-iOS14, founder de Mobile Dev Memo (publication paywalled de référence du secteur, 12 ans de year-ahead predictions consécutifs) et de Heracles Capital ($10M Fund I, thèse "Mobile is Still the Next Big Thing"), author de "Freemium Economics" (Morgan Kaufmann 2014, le playbook in-app monetization), ancien growth chez Skype / Wooga / Rovio. Conférencier headline MAU Vegas + GameDev. Investor / advisor INCRMNTAL.

Le skill couvre :
- **7 mental models** : Post-iOS14 Attribution Reality, SKAN Mechanics+Limits, SAN Black-Box Reading, MMP Switching Math, Bayesian MMM Renaissance, Geo-Incrementality Gold Standard, iOS-vs-Android UA Asymmetry
- **9 decision heuristics** opérationnelles avec mécanismes nommés (ATT opt-in benchmarks, SKAN k-anonymity, SAN over-claim arithmetic, MMM build-vs-buy thresholds)
- **Mode CONSULTATION** (audit / diagnostic / read) + **Mode PRODUCTION** (deliverable structuré : attribution stack recommendation, SKAN conversion-value schema, MMM build spec, geo-incrementality test design)
- **Voix première personne** académique-rigoureuse, post-graduate-level math, anti-snake-oil, "show your math", named-source citations
- **12 anti-patterns explicites** dont anti-last-click-attribution-2026, anti-single-MMP-source-of-truth, anti-SKAN-without-MMM-overlay, anti-probabilistic-without-validation, anti-fingerprinting, anti-vendor-neutrality-washing
- **6 test signatures** : Mechanism Test, Triangulation Test, Show-Your-Math Test, Specificity Test, Anti-Snake-Oil Test, Era-Calibration Test

## Sources canoniques distillées

### 1st-hand (production de Seufert)
- mobiledevmemo.com — publication principale (paywalled + free essays). Essays clés référencés :
  - "App Tracking Transparency Codex: the ultimate guide to ATT, IDFA deprecation, and SKAdNetwork"
  - "How to scale and optimize marketing spend with SKAdNetwork"
  - "Is SKAdNetwork 4.0 a turning point for mobile advertising: Privacy with Purpose?"
  - "Media mix models are the future of mobile advertising"
  - "Integrating a Media Mix Model into a digital marketing workflow"
  - "Why media mix modeling (MMM) fails"
  - "Pyrrhic privacy" / "Brute force privacy"
  - "Commerce at the limit"
  - "Apple privileges its own ad network with ATT. What's its privacy endgame?"
  - "2026 predictions for mobile marketing" (paywalled — indirectement cité)
  - 12 consecutive years of year-ahead predictions essays
- Twitter / X @eric_seufert — running commentary, thread-format analyses, Heracles thesis posts
- "Freemium Economics" (Morgan Kaufmann, 2014) — book on in-app monetization, the canonical mobile gaming playbook
- Heracles Capital + Heracles Media public material (hrcls.co)

### 2nd-hand (interviews externes + conferences)
- 9 Operators Podcast E069 — "Why Great Marketers Think Like Data Scientists, With Eric Seufert"
- Mobile Heroes podcast appearances (Liftoff)
- INCRMNTAL Q&A — "Orchestrating Measurements: Eric Seufert Analyst & Investor Mobile Dev Memo & Heracles Capital"
- PocketGamer.biz interview — "UA MegaTrends guy Eric Seufert on setting up Heracles, a boutique agency providing CMO smarts"
- MAU Vegas headline talks (annual)
- GameDev / Pocket Gamer Connects talks
- AppLovin / Bytedance / Meta marketing science conference appearances
- Muck Rack journalist profile

### Données externes / canonical references
- Apple Developer SKAdNetwork release notes (SKAN 2.x / 3.x / 4.x)
- Apple ATT framework documentation
- Adjust + AppsFlyer + Singular + Branch + Kochava annual benchmark reports (ATT opt-in rates, SKAN postback distributions, CPI by category)
- Google Privacy Sandbox Attribution Reporting API documentation
- Google Meridian (open-sourced Bayesian MMM) documentation + PyMC-Marketing case studies
- INCRMNTAL public benchmark data + AdExchanger coverage of $4.1M seed
- Industry CPI / ROAS benchmarks (Liftoff, AppLovin Marketing Science, Meta marketing science)

## Modifications par rapport aux sources

Le frontmatter `name:` est `promote-seufert-mobile-attribution` (préfixe `promote-` pour cohérence de namespace dans `promote/skills/`; suffixe `-mobile-attribution` pour scoper au domain technique précis et éviter overlap avec d'autres écoles d'attribution si Seufert élargissait son corpus).

Le skill suit le **gabarit promote-mcgarry-newsletter** (la persona-incarnée operator-class la plus récente du corpus) en termes de structure, mais adapté pour :
- Persona ANALYSTE-INVESTOR-STRATEGIST (pas opérateur agency-side) → plus académique, plus de mécanismes nommés, plus de citations primaires
- Domain mobile UA + attribution vs newsletter monetization → vocabulaire technique différent (ATT, SKAN, MMP, SAN, MMM, AXON, Meridian, Privacy Sandbox vs CPA, CPM, Sparkloop, Boosts)
- Voix academic-rigorous (vs operator-practitioner de McGarry) → sentences plus longues autorisées (12-25 mots), em-dashes pour précision analytique, named-source citations en standard
- Mode PRODUCTION enrichi avec section "Residual Uncertainty" et "Stack (current vs target state)" — reflète la discipline analyst-class de Seufert (always name what you don't know)
- 7 modèles (vs 6) car le domain technique requiert un cadrage iOS-vs-Android dédié + un MMP switching math dédié

## Pipeline integration (CRITIQUE pour P3.F strategist)

Ce skill est consulté par `promote-strategist` en **P3 étape m** (référence `delegation-matrix.md`) lors de la production de `10-instrumentation.md`, **quand mobile/paid attribution est en jeu**. Le strategist détecte le signal mobile (présence d'app iOS/Android dans STATE, paid UA spend annoncé, SKAN ou ATT mentionnés) et route vers ce skill plutôt que de se contenter de `references/attribution-canon.md` (qui est web-and-B2B-centric).

Le pivot doctrinal post-iOS14 que ce skill apporte :
- Là où `attribution-canon.md` propose self-reported + multi-touch + modeled comme triangle B2B, ce skill ajoute SKAN + SAN + Bayesian MMM + geo-incrementality comme stack mobile post-ATT
- Là où le strategist par défaut recommanderait "track UTM + GA4", ce skill rejette explicitement le frame last-click sur iOS et impose la triangulation 3-5-numéros
- Là où un consultant générique recommanderait un MMP comme source of truth, ce skill traite le MMP comme plumbing et impose un MMM overlay au-dessus de $100K/month spend

## Pattern Compliance (skill-grammar.md, 15/15)

- [x] Pattern 1 — Pipeline Position : section dédiée + after/before explicit (strategist P3.F → seufert → hormozi/schwartz). Reference relationship explicite avec attribution-canon.md
- [x] Pattern 2 — What you are NOT : "Frontiers" + 7 NEVER explicites + "What I am not" dans Identity Card
- [x] Pattern 3 — Frontmatter trigger ET non-trigger : "Trigger when..." (longue liste mobile-spécifique) + "Do NOT trigger for..." (web-only, pure B2B SaaS, creative, biographical)
- [x] Pattern 4 — BEFORE-MANDATORY : Step 1 classification + tool decision rules + research dimensions A-E (5 places to check)
- [x] Pattern 5 — Genre-adjusted thresholds : ATT opt-in benchmarks par catégorie (gaming 30-40%, utilities <15%); CPI iOS-vs-Android; budget split rules par tier de marché
- [x] Pattern 6 — Strengths to PRESERVE : implicit dans Mode CONSULTATION (don't degrade existing voice/results) + Limits sections per model
- [x] Pattern 7 — Max iterations + escalation : "Max 2 revisions before escalation back to user" dans Test Signature
- [x] Pattern 8 — Test signature : 6 tests reproductibles nommés (Mechanism, Triangulation, Show-Your-Math, Specificity, Anti-Snake-Oil, Era-Calibration)
- [x] Pattern 9 — Numbered N moves : 7 mental models + 9 heuristics + 12 anti-patterns + 6 hook formulas + 5 research dimensions + 7 NEVER frontiers
- [x] Pattern 10 — YAML state file : N/A (skill stateless de type Persona-incarnée, sous-école D)
- [x] Pattern 11 — Dispatch templates : Output Structure (PRODUCTION mode) avec 7 sections fixes (Diagnosis / Stack / Math-Mechanics / Plan / Benchmarks / Residual Uncertainty / Sign-off)
- [x] Pattern 12 — Output structuré : artifact PRODUCTION en 7 sections fixes documentées
- [x] Pattern 13 — V-tag versioning : `version: 0.1.0` + Changelog
- [x] Pattern 14 — Voix impérative + première personne : "Use 'I' — never 'Seufert would say'" + Role-Play Rules section
- [x] Pattern 15 — Anti-patterns explicites : 12 anti-patterns numérotés dans section dédiée, dont les 4 critiques demandés (anti-last-click-2026, anti-single-MMP-truth, anti-SKAN-without-MMM, anti-probabilistic-without-validation) + bonus (anti-fingerprinting, anti-vendor-neutrality-washing)

**Score : 15/15** (Pattern 10 N/A car persona-incarnée stateless, conformément à la sous-école D du skill-grammar).

## Sous-école stylistique

**Sous-école D (Persona-incarnée)**, conforme à `promote-hormozi`, `promote-mcgarry-newsletter`, `promote-paul-graham`, `promote-ammar`, `promote-steve-jobs`. Caractéristiques alignées :
- Voix première personne marquée + Role-Play Rules explicites
- Frameworks mentaux + heuristiques + angles morts (Honest Boundaries section)
- Ton consistent (analyst-investor-strategist, post-graduate-level math literacy, anti-snake-oil, named-source citations)
- Longueur ~580 lignes (cible 250-400, dépassement justifié par la densité technique du domain — SKAN mechanics + MMM math + geo-test design + vendor landscape)

## Voix : différenciation vs autres operator-personas du corpus

| Persona | Voix | Cadence | Vocabulaire signature |
|---|---|---|---|
| **Hormozi** | operator-bro decree | sentences courtes, parallélisme binaire | offer / leverage / volume / value equation |
| **McGarry** | operator practitioner calm | numbers in every paragraph, tier tables | CPA / CPM / Sparkloop / Boosts / Meta |
| **Paul Graham** | essayist contrarian | longues sentences, philosophical asides | startups / hackers / make something people want |
| **Seufert** (this skill) | analyst-investor-strategist | precise 12-25 word sentences, em-dashes, named mechanisms | SKAN / ATT / SAN / MMP / Bayesian MMM / geo-incrementality |

Le pivot voice-engineering : Seufert est le seul du corpus dont la **crédibilité opérationnelle dépend de citer la mécanique sous-jacente** (postback windows, k-anonymity thresholds, adstock decay). Là où Hormozi décrète et McGarry montre les chiffres, Seufert **ouvre la black box et nomme le mécanisme**. La discipline est différente.

## Snapshot d'origine

Pas de snapshot — skill créé from scratch via distillation web (huashu-nuwa). Sources canoniques listées ci-dessus restent les références primaires. Note : les positions les plus récentes de Seufert (2026 predictions essay, paywalled-only) ne sont distillées qu'indirectement via les positions tracées dans les essays publics et conference talks; le skill doit être re-verifié contre la dernière publication paywalled pour les prises forward-looking.

## Licence

Le contenu distillé est dérivé de sources publiques (blog free-tier + paywalled context cited indirectly, Twitter, podcast appearances, conference talks, book Freemium Economics, public Heracles material). Le SKILL.md lui-même (organisation, frameworks, voix encodée) est le travail de distillation de François Neumann. À vérifier avant redistribution publique. Si redistribué, créditer Eric Seufert comme persona source, Mobile Dev Memo comme publication source, Heracles Capital + Heracles Media comme contexte professionnel, et François Neumann comme distillateur.
