# promote

Système autonome de promotion produit, distribuable comme plugin Claude Code. Donne-lui une URL, il pose les bonnes questions sur le produit, produit une stratégie de niveau consultant senior, et passe la main à un exécuteur qui se charge du posting et de l'itération sur les canaux.

## Deux parties

- **Partie 1 — `promote-strategist`** *(v1.0.0)* : audit + génération de stratégie. Prend une URL, pose un maximum de questions sur le produit (jamais sur la méthode), produit un dossier de stratégie complet via 15 délégations orchestrées (Hormozi, Schwartz, Dunford, Cialdini, Voss, Holiday, Ammar, x-mastery, MrBeast, GEO, etc.).
- **Partie 2 — `promote-executor`** *(en développement)* : consomme `strategy/handoff-to-executor.yaml`, gère credentials/MCPs/cron, génère drafts, post sur les canaux, mesure et itère.

## Install

### Mode 1 — Plugin Claude Code (production, recommandé)

```bash
/plugin marketplace add kalaspace/promote
/plugin install promote@promote-marketplace
/reload-plugins
# invocation : /promote:promote-strategist <url>
```

Les skills atterrissent dans `~/.claude/plugins/cache/promote/<version>/` et sont accessibles globalement.

### Mode 2 — Multi-agent (Cursor / Codex / Gemini en plus de Claude Code)

```bash
npx skills add kalaspace/promote -g
# copie les skills dans ~/.claude/skills/, ~/.cursor/, ~/.codex/, ~/.gemini/
```

### Mode 3 — Dev local (contribute / fork)

```bash
git clone kalaspace/promote
cd promote
./install.sh    # crée les symlinks .claude/skills/promote-* → ../../skills/
# invocation : /promote-strategist <url>  (scope projet, depuis ce repo)
```

## Configuration runtime

Le strategist écrit ses artefacts (campagnes) selon cette hiérarchie de résolution :

1. **`$PROMOTE_HOME`** env var (override absolu) — `export PROMOTE_HOME=/path/to/store`.
2. **`./campaigns/`** relatif au cwd (défaut). Recommandé : tu lances `/promote-strategist <url>` depuis le dossier de ton produit/projet, les artefacts y sont écrits, versionnables avec git.
3. **`${CLAUDE_PLUGIN_DATA}/campaigns/`** fallback si cwd non-writable.

## Architecture

```
.claude-plugin/
├── marketplace.json              catalogue (1 plugin)
└── plugin.json                   manifest "promote"

skills/                           20 skills, source de vérité
├── promote-strategist/           orchestrateur (entry point)
├── promote-hormozi/              operator personas (10)
├── promote-schwartz/
├── promote-cialdini/
├── promote-voss/
├── promote-holiday/
├── promote-ammar/
├── promote-paul-graham/
├── promote-x-mastery/
├── promote-mrbeast/
├── promote-steve-jobs/
├── promote-customer-research/    cherry-picked tactical (2)
├── promote-pricing-strategy/
├── promote-jtbd-switch/          framework skills (6)
├── promote-dunford-positioning/
├── promote-growth-four-fits/
├── promote-plg-design/
├── promote-geo-optimization/
├── promote-ai-content-pipeline/
└── promote-huashu-nuwa/          utility (skill builder)

references/                       11 validateurs canoniques
├── skill-grammar.md             grammaire de construction des skills
├── strategy-kernel.md           Rumelt
├── category-design.md           Play Bigger
├── growth-loops.md              Reforge
├── metrics-canon.md             North Star
├── psychology-canon.md          Cialdini + Ariely + Kahneman
├── sales-canon.md               SPIN + JOLT
├── demand-gen.md                Refine Labs
├── attribution-canon.md         dark social
├── network-effects.md           Cold Start
└── copy-frameworks.md           PAS / AIDA

campaigns/{slug}/                 runtime par campagne (gitignored)
├── STATE.yaml
├── intake/                       crawl URL + 5 batches questions
├── research/                     market + ICP
└── strategy/                     livrable final (14 fichiers + handoff YAML)
```

## Pipeline du strategist (5 phases)

```
P0 INTAKE             crawl URL → metadata extraction
P1 PRODUCT DEEP DIVE  5 batches de questions sur LE PRODUIT
P2 MARKET RESEARCH    WebSearch + ICP triangulation
P3 STRATEGY SYNTHESIS 15 délégations orchestrées (Rumelt → JTBD → Category+Dunford →
                      Hormozi → Schwartz → Ammar → Four-Fits → PLG → Cialdini →
                      x-mastery → MrBeast → GEO → Demand-gen+Attribution → PG → Rumelt)
P4 PACKAGING          14 artefacts + handoff-to-executor.yaml + checklist 40 points
```

## Plan complet

Voir `/home/kala/.claude/plans/le-but-est-nifty-creek.md`.

## Statut

- **Phases 0-4** : DONE (build de la Partie 1).
- **Phase 5** : DONE (distribution packaging — plugin manifests, symlinks, multi-agent).
- **Phase 6** : à venir (`promote-executor`).

## Licence

MIT (orchestration, references, templates, distillations originales). Les skills importés depuis des repos publics conservent leurs licenses (MIT pour wondelai, coreyhaines). Voir `docs/attributions.md` et `_ATTRIBUTIONS.md` dans chaque dossier de skill.
