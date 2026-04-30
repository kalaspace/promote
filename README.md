# promote

Système autonome de promotion produit, distribuable comme plugin Claude Code. Donne-lui une URL, il pose les bonnes questions sur le produit, valide un ledger de claims factuels avec toi (15 min), propose un mix de canaux multi-plateforme (au-delà de ce que tu mentionnes), produit une stratégie de niveau consultant senior + 14 jours de contenu concret prêt-à-coller, et te laisse convertir le reste à la demande — le tout sans inventer de faits sur ton produit.

## Deux entry points exposés (v1.3.0)

- **`/promote:promote-strategist <url>`** : pipeline complet 6 phases. Crawl URL → 5 batches de questions sur le produit → **P1.5 ledger de claims factuels (15 min user review)** → recherche marché → 5 sub-phases de stratégie (P3.A-E, two-pass orchestration) → 14 jours de contenu concret avec 8 quality gates (incl. fact-check + reader-honesty) + 76 jours d'outlines. ~1.2-1.3M tokens par campagne (15-20% de réduction vs v1.2.0).
- **`/promote:promote-content-batcher <campaign-slug>`** : convertit les outlines en posts concrets à la demande (J+14, J+28, J+42, etc.) avec les mêmes 8 gates et le même fact-check ledger.

**v1.3.0 BREAKING change** vs v1.2.0 :

- **Ledger de claims factuels (P1.5)** : nouvelle phase qui extrait les affirmations factuelles de l'intake en CSV. Tu valides en 15 min. Tout post produit downstream est cross-checké contre ce ledger.
- **Quality Gate #7 (fact-check) + #8 (reader-honesty)** : chaque post passe une vérification factuelle + un audit du ratio "lecteur-first" (cible ≥70%). Pas de fabrication, pas d'auto-promo masquée.
- **Output schema split** : chaque post = 2 fichiers. `content/posts/{slug}.md` = pur contenu prêt à copier-coller. `content/posts/.meta/{slug}.yaml` = metadata complète (audit gates, asset specs, etc.).
- **Anti-fabrication contract** : injecté par référence dans tous les 34 prompts internes (16 operators + 9 personas + 8 frameworks + 1 orchestrator).
- **Aggressive trim P3** : `strategy/09-geo-plan.md` cut entièrement (defer post-J+30) ; `strategy/10-instrumentation.md` trimmé en `10-tripwires-top3.md` ; `strategy/11-content-calendar-90d.csv` trimmé en `11-content-calendar-14d-then-outline.csv` ; Rumelt-Aval opt-in via flag `--rumelt-aval`.

Si tu invoquais directement `/promote:welsh-linkedin` etc. (v1.1.0 pattern), ça ne marche plus depuis v1.2.0 — utilise le strategist (qui orchestre tout en interne via Read+Task).

## Install

### Mode 1 — Plugin Claude Code (production, recommandé)

```bash
/plugin marketplace add kalaspace/promote
/plugin install promote@promote-marketplace
/reload-plugins
# invocation : /promote:promote-strategist <url>
```

Mise à jour vers v1.3.0 si déjà installé en v1.2.0 :

```bash
/plugin marketplace update promote-marketplace
/plugin update promote
/reload-plugins
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

## Workflow utilisateur v1.3.0

1. `/promote:promote-strategist <url>` depuis le dossier de ton produit.
2. Le strategist crawl + pose les 5 batches de questions sur le produit. Tu réponds.
3. **Le strategist génère `intake/verified-claims.csv`** avec ~30 claims extraites de tes réponses. Il te demande : *"Review en 15 min : valide / rejette / édite. Ajoute des never-claims (phrasings que tu refuses qu'on dise sur ton produit)."*
4. Tu reviews le CSV (Excel / éditeur), édites le `never-claims.txt` si nécessaire, dis "done".
5. Le strategist continue : recherche marché → strategy synthesis (P3.A-E) → P4 content production avec fact-check.
6. Tu reçois 14 posts concrets dans `content/posts/{slug}.md` (pur contenu prêt-à-coller). La metadata est dans `.meta/{slug}.yaml` adjacent (consultable mais hors lecture quotidienne).
7. À J+14, J+28, etc. : `/promote:promote-content-batcher <slug>` produit le batch suivant en consommant le même ledger.

## Configuration runtime

Le strategist écrit ses artefacts (campagnes) selon cette hiérarchie de résolution :

1. **`$PROMOTE_HOME`** env var (override absolu) — `export PROMOTE_HOME=/path/to/store`.
2. **`./campaigns/`** relatif au cwd (défaut). Recommandé : tu lances `/promote-strategist <url>` depuis le dossier de ton produit/projet, les artefacts y sont écrits, versionnables avec git.
3. **`${CLAUDE_PLUGIN_DATA}/campaigns/`** fallback si cwd non-writable.

## Architecture v1.3.0

```
.claude-plugin/
├── marketplace.json
└── plugin.json

skills/                          # 2 entry points exposés (visibles dans system prompt)
├── promote-strategist/          # pipeline complet URL → strategy + ledger + 14j concrets
└── promote-content-batcher/     # outline → concret on demand (avec fact-check)

prompts/                         # 37 internal expert prompts (NON-skills, lus via Read+Task)
├── operators/                   # 16 operators v1.1 (Welsh, McGarry, Faris, Wilcox, ...)
├── orchestrators/               # 1 (channel-strategist)
├── personas/                    # 9 (Hormozi, Schwartz, Holiday, Ammar, PG, X-Mastery,
│                                #     MrBeast, Steve Jobs, Gerhardt-Founder)
├── frameworks/                  # 8 (JTBD, Dunford, Cialdini, Voss, Four-Fits,
│                                #     PLG, GEO, AI-Content)
├── tactical/                    # 2 (customer-research, pricing-strategy)
└── utility/                     # 4 (huashu-nuwa, claims-extractor, fact-checker,
                                 #    reader-honesty-judge)

references/                      # 22 validateurs canoniques (Rumelt, North Star,
│                                #   psychology-canon, sales-canon, demand-gen,
│                                #   attribution-canon, content-production,
│                                #   anti-fabrication-contract, claims-ledger-spec, etc.)

campaigns/{slug}/                # runtime par campagne (gitignored)
├── STATE.yaml
├── intake/                      # crawl URL + 5 batches questions
│   ├── url-crawl.md
│   ├── batch-{1..5}-*.md
│   ├── verified-claims.csv      ← NEW v1.3.0 (ledger validé user)
│   └── never-claims.txt         ← NEW v1.3.0
├── research/                    # market + ICP
├── strategy/
│   ├── 00-product-brief.md
│   ├── 02-jtbd-switch.md → 08-channel-strategy.md
│   ├── 10-tripwires-top3.md     ← RENAMED v1.3.0 (était 10-instrumentation.md)
│   ├── 11-content-calendar-14d-then-outline.csv  ← RENAMED v1.3.0
│   ├── strategy-summary.md
│   ├── handoff-to-executor.yaml
│   └── operator-consultations/  # consultations strategic + narrative_hypotheses
└── content/
    ├── posts/
    │   ├── {slug}.md            ← v1.3.0 schema split — PURE CONTENT prêt-à-coller
    │   └── .meta/{slug}.yaml    ← v1.3.0 schema split — METADATA complète
    └── batch-reports/           # rapports content-batcher
```

**Files NOT generated by default v1.3.0** (vs v1.2.0) :
- `strategy/09-geo-plan.md` — CUT (defer to standalone `promote-geo-strategist` v1.3.1+)
- `strategy/p3g-rumelt-aval.md` — opt-in via flag `--rumelt-aval` (renamed `p3f-rumelt-aval.md`)

## Pipeline du strategist v1.3.0 (6 phases, P3 en 5 sub-phases)

```
P0 INTAKE             crawl URL → metadata extraction
P1 PRODUCT DEEP DIVE  5 batches de questions sur LE PRODUIT
P1.5 CLAIMS LEDGER    extraction claims factuels → user valide en 15 min ← NEW v1.3.0
P2 MARKET RESEARCH    WebSearch + ICP triangulation
P3 STRATEGY SYNTHESIS Two-pass orchestration en 5 sub-phases :
  P3.A — Foundations (Rumelt mental, JTBD, Positioning, Hormozi, Schwartz, Ammar,
         Four-Fits, PLG, Cialdini, PG)
  P3.B — Channel mix initial (channel-strategist propose 4-7 canaux)
  P3.C — Strategic consultation (chaque operator consulté avec ledger en contexte,
         narrative_hypotheses pour angles non-sourcés)
  P3.D — Mix refinement & conflict resolution
  P3.E — Pillars + cadence + voice + top-3 tripwires consolidation
  [P3.F Rumelt-Aval — OPT-IN via flag --rumelt-aval]
P4 CONTENT PRODUCTION 14-DAY  posts J0-J13 via operators (Read+Task), 8 quality gates
                              (#7 fact-check + #8 reader-honesty), schema split
                              .md + .meta.yaml
P5 PACKAGING          11 artefacts + handoff-to-executor.yaml + checklist 28 points
```

## Statut

- **Phases 0-5 (v1.0.0)** : DONE.
- **Phase 7 (v1.1.0)** : DONE. Two-pass orchestration + 17 operators + content-batcher.
- **Phase 8 (v1.2.0)** : DONE. Hide internal skills (2 exposés, 37 internes via Read+Task).
- **Phase 9 (v1.3.0)** : DONE. Quality + Verification + Lean (ledger + gates #7+#8 + schema split + trim P3).
- **Phase 6 (executor)** : à venir, post-v1.3.0. Posting réel via MCPs + cron + analytics.

## Plan complet

Voir `/home/kala/.claude/plans/le-but-est-nifty-creek.md`.

## Licence

MIT (orchestration, references, templates, distillations originales). Les prompts importés depuis des repos publics conservent leurs licenses (MIT pour wondelai, coreyhaines). Voir `docs/attributions.md` et `_ATTRIBUTIONS.md` dans chaque dossier de prompt.
