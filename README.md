# promote

Système autonome de promotion produit, distribuable comme plugin Claude Code. Donne-lui une URL, il pose les bonnes questions sur le produit, propose un mix de canaux multi-plateforme (au-delà de ce que tu mentionnes), produit une stratégie de niveau consultant senior + 14 jours de contenu concret, et te laisse convertir le reste à la demande.

## Deux entry points exposés (v1.2.0)

- **`/promote:promote-strategist <url>`** : pipeline complet. Crawl URL → 5 batches de questions sur le produit → recherche marché → 7 sub-phases de stratégie (avec consultations operators en mode strategic) → 14 jours de contenu concret + 76 jours d'outlines. ~80-120K tokens par campagne.
- **`/promote:promote-content-batcher <campaign-slug>`** : convertit les outlines en posts concrets à la demande (J+14, J+28, J+42, etc.).

**v1.2.0 BREAKING change** : seuls 2 skills sont visibles dans le system prompt de Claude. Les 37 sous-skills (operators, frameworks, personas) sont des **prompts internes** sous `prompts/`, invoqués via Read+Task tool. Plus de pollution du system prompt. Si tu invoquais directement `/promote:welsh-linkedin` etc. en v1.1.0, ça ne marche plus — utilise le strategist (qui orchestre tout en interne).

## Install

### Mode 1 — Plugin Claude Code (production, recommandé)

```bash
/plugin marketplace add kalaspace/promote
/plugin install promote@promote-marketplace
/reload-plugins
# invocation : /promote:promote-strategist <url>
```

### Mode 2 — Multi-agent (Cursor / Codex / Gemini en plus de Claude Code)

```bash
npx skills add kalaspace/promote -g
# copie les 2 skills exposés dans ~/.claude/skills/, ~/.cursor/, ~/.codex/, ~/.gemini/
```

### Mode 3 — Dev local (contribute / fork)

```bash
git clone https://github.com/kalaspace/promote
cd promote
./install.sh    # crée 2 symlinks .claude/skills/{promote-strategist,promote-content-batcher} → ../../skills/
# invocation : /promote-strategist <url>  (scope projet, depuis ce repo)
```

## Configuration runtime

Le strategist écrit ses artefacts (campagnes) selon cette hiérarchie de résolution :

1. **`$PROMOTE_HOME`** env var (override absolu) — `export PROMOTE_HOME=/path/to/store`.
2. **`./campaigns/`** relatif au cwd (défaut). Recommandé : tu lances `/promote-strategist <url>` depuis le dossier de ton produit/projet, les artefacts y sont écrits, versionnables avec git.
3. **`${CLAUDE_PLUGIN_DATA}/campaigns/`** fallback si cwd non-writable.

## Architecture v1.2.0

```
.claude-plugin/
├── marketplace.json
└── plugin.json

skills/                          # 2 entry points exposés (visibles dans system prompt)
├── promote-strategist/          # pipeline complet URL → strategy + 14j concrets
└── promote-content-batcher/     # outline → concret on demand

prompts/                         # 37 internal expert prompts (NON-skills, lus via Read+Task)
├── operators/                   # 16 operators v1.1 (Welsh, McGarry, Faris, Wilcox, ...)
├── orchestrators/               # 1 (channel-strategist)
├── personas/                    # 9 (Hormozi, Schwartz, Holiday, Ammar, PG, X-Mastery,
│                                #     MrBeast, Steve Jobs, Gerhardt-Founder)
├── frameworks/                  # 8 (JTBD, Dunford, Cialdini, Voss, Four-Fits,
│                                #     PLG, GEO, AI-Content)
├── tactical/                    # 2 (customer-research, pricing-strategy)
└── utility/                     # 1 (huashu-nuwa skill builder)

references/                      # 20 validateurs canoniques (Rumelt, North Star,
│                                #   psychology-canon, sales-canon, demand-gen,
│                                #   attribution-canon, content-production, etc.)

campaigns/{slug}/                # runtime par campagne (gitignored)
├── STATE.yaml
├── intake/                      # crawl URL + 5 batches questions
├── research/                    # market + ICP
├── strategy/
│   ├── 00-product-brief.md → 11-content-calendar-90d.csv
│   ├── strategy-summary.md
│   ├── handoff-to-executor.yaml
│   └── operator-consultations/  # consultations strategic des 17 operators (P3.C)
└── content/
    ├── posts/                   # 14j concrets (P4) + batches additionnels
    └── batch-reports/           # rapports content-batcher
```

## Pipeline du strategist (5 phases, P3 split en 7 sub-phases)

```
P0 INTAKE             crawl URL → metadata extraction
P1 PRODUCT DEEP DIVE  5 batches de questions sur LE PRODUIT
P2 MARKET RESEARCH    WebSearch + ICP triangulation
P3 STRATEGY SYNTHESIS Two-pass orchestration en 7 sub-phases :
  P3.A — Foundations (Rumelt, JTBD, Positioning, Hormozi, Schwartz, Ammar, Four-Fits, PLG, Cialdini, PG)
  P3.B — Channel mix initial (channel-strategist propose 4-7 canaux)
  P3.C — Strategic consultation (chaque operator consulté en mode strategic, output structuré sauvé)
  P3.D — Mix refinement & conflict resolution (channel-strategist arbitre)
  P3.E — Pillars + cadence + voice consolidation
  P3.F — GEO + Instrumentation strategic consultation (Indig, Faris, Seufert, Holiday)
  P3.G — Rumelt validator AVAL
P4 CONTENT PRODUCTION 14-DAY  posts concrets J0-J13 via operators (Read+Task)
P5 PACKAGING          14 artefacts + handoff-to-executor.yaml + checklist 40 points
```

## Statut

- **Phases 0-7** : DONE.
- **Phase 8 (v1.2.0)** : DONE. 2 skills exposés, 37 internes invisibles.
- **Phase 6 (executor)** : à venir, moins urgent depuis v1.1.0+ (le strategist + content-batcher couvrent déjà la production de contenu).

## Plan complet

Voir `/home/kala/.claude/plans/le-but-est-nifty-creek.md`.

## Licence

MIT (orchestration, references, templates, distillations originales). Les prompts importés depuis des repos publics conservent leurs licenses (MIT pour wondelai, coreyhaines). Voir `docs/attributions.md` et `_ATTRIBUTIONS.md` dans chaque dossier de prompt.
