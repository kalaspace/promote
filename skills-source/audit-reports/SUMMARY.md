# Audit summary — Phase 0.B (skills publics)

Date : 2026-04-28

Synthèse des décisions KEEP / CHERRY-PICK / REBUILD / SKIP par skill audité depuis les repos publics clonés dans `skills-source/from-public/`.

## Repos clonés

| Repo | Source | Taille | Skills inspectés |
|---|---|---|---|
| `anthropic-skills` | github.com/anthropics/skills | 15M | 17 (génériques tech, pas marketing) |
| `wondelai-skills` | github.com/wondelai/skills | 7.8M | 39 (distillations livres canoniques, MIT) |
| `coreyhaines-marketingskills` | github.com/coreyhaines31/marketingskills | 4.0M | 39 (skills marketing tactiques) |
| `ericosiu-ai-marketing-skills` | github.com/ericosiu/ai-marketing-skills | 2.7M | 21 (skills opérationnels avec méthodologie expérimentale) |

Repo non cloné (pas trouvé en libre accès au moment de l'audit) : `typefully/agent-skills`, `realkimbarrett/advertising-skills`. À retenter en Phase 5 (executor) si besoin.

## Décisions

### KEEP — importés dans `.claude/skills/promote-*` avec rename

Ces skills couvrent les **must-have** Tier-1 du plan d'origine, à un niveau de profondeur opérationnel (250-400 lignes SKILL.md + 5-11 références). Aucun besoin de les rebuild via huashu-nuwa.

| Skill source | Renommé en | Couvre |
|---|---|---|
| `wondelai-skills/obviously-awesome` | `promote-dunford-positioning` | **Phase 2 framework** — April Dunford positioning canonique |
| `wondelai-skills/jobs-to-be-done` | `promote-jtbd-switch` | **Phase 2 framework** — JTBD (Christensen + Moesta) |
| `wondelai-skills/negotiation` | `promote-voss` | **Phase 1 operator Tier-1** — Chris Voss tactical empathy |
| `wondelai-skills/influence-psychology` | `promote-cialdini` | **Phase 1 operator Tier-1** — Cialdini 7 principles |
| `coreyhaines/skills/pricing-strategy` | `promote-pricing-strategy` | Bonus — utile pour P3 du strategist (pricing complémentaire à Hormozi) |
| `coreyhaines/skills/customer-research` | `promote-customer-research` | Bonus — utile pour P2 du strategist (ICP via Reddit/G2/VOC mining) |

Tous patches effectués :
1. Frontmatter `name:` mis à jour avec préfixe `promote-`.
2. Cross-skill references dans `description:` re-routées vers les nouveaux noms préfixés (ex: `see jobs-to-be-done` → `see promote-jtbd-switch`).
3. Suggestions vers des skills externes non importés (ex: `crossing-the-chasm`, `paywall-upgrade-cro`, `copywriting`, `page-cro`) retirées.
4. `_ATTRIBUTIONS.md` créé dans chaque dossier.

### REBUILD — à créer en Phase 1/2 via `promote-huashu-nuwa`

Skills must-have non couverts par les imports publics :

| Skill à créer | Phase | Pourquoi rebuild |
|---|---|---|
| `promote-schwartz` | 1 (operator Tier-1) | Eugene Schwartz (5 stages of awareness, 3 levels of sophistication) — aucun équivalent dans les repos publics. Pierre de Rosette du copy. |
| `promote-holiday` | 1 (operator Tier-1) | Ryan Holiday (PR/earned media, Trading Up The Chain) — aucun équivalent. Zone vide. |
| `promote-growth-four-fits` | 2 (framework) | Brian Balfour (Reforge Four Fits) — pas dans wondelai. Pourrait s'appuyer sur des extraits de coreyhaines/revops si pertinent, mais le framework Balfour mérite un skill dédié. |
| `promote-plg-design` | 2 (framework) | PLG2.0 (Wes Bush + Reforge) — pas couvert ; nécessite la nuance "PLG-only refusé par défaut, force choix explicite". |
| `promote-geo-optimization` | 2 (framework) | **CRITIQUE 2026** — Generative Engine Optimization (papier Aggarwal 2023). Pas dans aucun repo audité. Différenciateur 2026. |
| `promote-ai-content-pipeline` | 2 (framework) | System-of-prompts orchestré (Mollick + Reforge guides 2025). Pas dans aucun repo audité. |

### SKIP — explicitement écartés

| Skill skipped | Raison |
|---|---|
| `wondelai/hundred-million-offers` | Doublon. Le skill local `promote-hormozi` (308K) est plus riche : voix incarnée, 6 dimensions de research, decision logs, court filings cited. |
| `wondelai/storybrand-messaging` | Templatisé (SB7 = monomythe Campbell). Plan d'origine l'écarte (remplacé par JTBD-Switch + Cialdini). |
| `wondelai/blue-ocean-strategy` | Référence dans `references/category-design.md` à venir, pas un skill. |
| `wondelai/crossing-the-chasm` | Référence ; absorbée dans `promote-dunford-positioning` comme "chasm checkpoint". |
| `wondelai/lean-startup`, `wondelai/inspired-product`, etc. | Out-of-scope pour la Partie 1 (stratégie de promotion produit). Utiles pour product management, pas pour la promo. |
| `anthropic-skills/*` | Aucun skill marketing dans le repo officiel Anthropic ; skills techniques génériques (canvas-design, frontend-design, slack-gif-creator, xlsx, pdf, etc.). |

### DEFER — pour Partie 2 (`promote-executor`), pas Partie 1

À ne PAS importer dans `.claude/skills/` maintenant. Reviendront pour la Partie 2 quand on construira l'executor (génération drafts + posting + analytics).

**coreyhaines (skills tactiques)** : `cold-email`, `email-sequence`, `paid-ads`, `seo-audit`, `programmatic-seo`, `ab-test-setup`, `referral-program`, `lead-magnets`, `copywriting`, `copy-editing`, `popup-cro`, `page-cro`, `paywall-upgrade-cro`, `signup-flow-cro`, `onboarding-cro`, `form-cro`, `aso-audit`, `community-marketing`, `competitor-profiling`, `competitor-alternatives`, `analytics-tracking`, `churn-prevention`, `directory-submissions`, `free-tool-strategy`, `launch-strategy`, `marketing-ideas`, `sales-enablement`, `schema-markup`, `site-architecture`, `social-content`, `video`, `image`, `ad-creative`, `revops`, `ai-seo`, `content-strategy`, `marketing-psychology` (probable doublon avec promote-cialdini, à vérifier en Partie 2), `product-marketing-context`.

**ericosiu (skills opérationnels)** : `growth-engine`, `seo-ops`, `content-eval`, `short-form-pipeline`, `podcast-ops`, `sales-pipeline`, `deck-generator`, `content-ops`, `clone-site`, `conversion-ops`, `revenue-intelligence`, `x-longform-post`, `video-clip-pipeline`, `lead-dossier`, `yt-competitive-analysis`, `sales-playbook`, `outbound-engine`, `team-ops`, `autoresearch`, `finance-ops`, `video-caption-generator`. Particulièrement `growth-engine` et `autoresearch` qui implémentent un framework expérimental autonome (bootstrap stats + auto-promote) — gold pour la Partie 2.

## Autonomie

Tous les 6 skills KEEP ont été audités pour autonomie :

- 0 chemin absolu détecté.
- Cross-skill references dans `description:` patchées vers les noms `promote-*` quand le skill cible existe dans le projet, sinon retirées.

Verdict global : **6/6 AUTONOMES après patches**.

## Bilan : volume de Phase 1/2 réduit

Plan d'origine : 5 operator skills + 6 framework skills = 11 skills à créer via huashu-nuwa.

**Après Phase 0.B** :
- Phase 1 (operators) : 2 à créer (`promote-schwartz`, `promote-holiday`) — 4 sur 5 fournis par wondelai et donc déjà installés.
- Phase 2 (frameworks) : 4 à créer (`promote-growth-four-fits`, `promote-plg-design`, `promote-geo-optimization`, `promote-ai-content-pipeline`) — 2 sur 6 fournis par wondelai (`promote-dunford-positioning`, `promote-jtbd-switch`).

**Total : 6 skills à créer** au lieu de 11. Gain : ~45% de volume de build, et qualité supérieure (les skills wondelai sont déjà battle-tested et MIT-licensed).
