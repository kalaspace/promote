# Architecture

## Overview

Système en deux parties :
1. **`promote-strategist`** (Partie 1) : URL → dossier de stratégie complet
2. **`promote-executor`** (Partie 2, à venir) : stratégie → exécution multi-canal

## Convention de nommage

Tous les skills sont préfixés `promote-` pour garantir un namespace unique au scope projet et éviter toute collision avec les skills globaux.

## Layers

```
┌──────────────────────────────────────────────────────────┐
│  promote-strategist  (orchestrateur, kitchen-sink)       │
└────┬───────────────────────────────────────────────────┬─┘
     │                                                    │
     ▼                                                    ▼
┌──────────────────────────┐         ┌────────────────────────────────────┐
│  Operator skills         │         │  Framework skills                  │
│  (persona-incarnée)      │         │  (scoped surgeon)                  │
│                          │         │                                    │
│  promote-hormozi         │         │  promote-jtbd-switch               │
│  promote-schwartz        │         │  promote-dunford-positioning       │
│  promote-dunford         │         │  promote-growth-four-fits          │
│  promote-cialdini        │         │  promote-plg-design                │
│  promote-voss            │         │  promote-geo-optimization          │
│  promote-holiday         │         │  promote-ai-content-pipeline       │
│  promote-x-mastery       │         │                                    │
│  promote-mrbeast         │         └────────────────────────────────────┘
│  promote-ammar           │
│  promote-paul-graham     │
│  promote-steve-jobs      │
└──────────────────────────┘
                                     ┌────────────────────────────────────┐
                                     │  references/  (validateurs)        │
                                     │                                    │
                                     │  skill-grammar.md  (chap 34)       │
                                     │  strategy-kernel.md  (Rumelt)      │
                                     │  category-design.md  (Play Bigger) │
                                     │  growth-loops.md  (Reforge)        │
                                     │  metrics-canon.md  (North Star)    │
                                     │  psychology-canon.md  (Cialdini)   │
                                     │  sales-canon.md  (SPIN+JOLT)       │
                                     │  demand-gen.md  (Refine Labs)      │
                                     │  attribution-canon.md  (dark soc)  │
                                     │  network-effects.md  (Cold Start)  │
                                     │  copy-frameworks.md  (PAS/AIDA)    │
                                     └────────────────────────────────────┘
```

## State management

Per-campagne sous `<runtime_root>/{slug}/` (le `runtime_root` est résolu en P0 selon la hiérarchie ci-dessous) :
- `STATE.yaml` : phase courante, batches répondus, decisions log, runtime_root
- `intake/` : crawl URL + 5 batches de questions
- `research/` : market research, ICP
- `strategy/` : livrable final (00-product-brief.md → 11-content-calendar-90d.csv + handoff-to-executor.yaml)

### Runtime root resolution

1. `$PROMOTE_HOME` env var (override absolu)
2. `./campaigns/` relatif au cwd (défaut, recommandé pour git/inspection)
3. `${CLAUDE_PLUGIN_DATA}/campaigns/` fallback si cwd non-writable

## Pipeline du strategist (5 phases)

```
P0 INTAKE         crawl URL → extract metadata
P1 PRODUCT DEEP DIVE    5 batches de questions sur LE PRODUIT
P2 MARKET RESEARCH      WebSearch + ICP triangulation
P3 STRATEGY SYNTHESIS   15 délégations orchestrées (Rumelt → JTBD → Category+Dunford →
                        Hormozi → Schwartz → Ammar → Four-Fits → PLG → Cialdini →
                        x-mastery → MrBeast → GEO → Demand-gen+Attribution → PG → Rumelt)
P4 PACKAGING           strategy/ + handoff-to-executor.yaml
```

## Distribuable

Le repo est packagé comme **plugin Claude Code** (spec Anthropic Agent Skills, marketplace.json + plugin.json). Aucune référence absolue hors du repo.

Trois modes d'install (voir `INSTALL.md`) :
1. **Plugin Claude Code** (`/plugin marketplace add` + `/plugin install`) — production.
2. **Multi-agent** (`npx skills add -g`) — Cursor, Codex, Gemini en plus.
3. **Dev local** (`./install.sh` après `git clone`) — symlinks `.claude/skills/promote-* → ../../skills/`.

Source de vérité = `skills/` à la racine (convention plugin). Pour le mode dev, `.claude/skills/` est généré à la volée par `install.sh` (gitignored).
