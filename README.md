# promote

Système autonome de promotion produit, distribuable comme plugin Claude Code. v1.4.0 : single skill, single invocation. Donne-lui une URL, il ingère le contenu de ton produit lui-même comme source de vérité (TOC pour livre, docs pour SaaS, syllabus pour cours), pose les bonnes questions sur le produit, valide un ledger de claims factuels avec toi (~20 min), produit une stratégie de niveau consultant senior + tous les posts concrets de la plage de temps prévue (default 90 jours, configurable) — le tout sans inventer de chapitres/modules/exemples qui ne sont pas littéralement dans ton produit.

## Un seul entry point exposé (v1.4.0)

- **`/promote:promote-strategist <url>`** : pipeline complet 7 phases en single-run.
  - P0 INTAKE (crawl URL)
  - **P0.5 PRODUCT CONTENT INGESTION (NEW v1.4.0)** : ingère le contenu structuré du produit (TOC/docs/syllabus selon type) dans `intake/product-content.md` — devient la source de vérité pour les claims STRUCTURE+EXAMPLES.
  - P1 PRODUCT DEEP DIVE (5 batches questions)
  - P1.5 CLAIMS LEDGER (extraction depuis batches + product-content.md, ~20 min user review)
  - P2 MARKET RESEARCH
  - P3 STRATEGY SYNTHESIS (5 sub-phases A-E, two-pass orchestration avec must_quote_from)
  - **P4 CONTENT PRODUCTION FULL-WINDOW (single-run v1.4.0)** : produit les posts concrets de toute la plage configurée (default 90 jours, `--days N` flag) en un run — pas de status outline, pas de re-invocation manuelle.
  - P5 PACKAGING

**v1.4.0 BREAKING changes** vs v1.3.0 :

- **Source-Truth Ledger** : le produit lui-même (TOC/docs/syllabus) devient la source primaire des claims STRUCTURE+EXAMPLES. Plus d'inférence depuis batches d'interview (qui produisaient des fabrications latentes type "chapitre prospection" sans validation TOC).
- **Quality Gate #7 enrichi** : 3 NEW sub-checks
  - #7.1 product grounding : un post promotionnel doit citer ≥1 STRUCTURE/EXAMPLES claim
  - #7.2 structural reference match : "chapitre 3" / "module 4" / "feature X" doit matcher un STRUCTURE claim, sinon REJECT_IMMEDIATE
  - #7.3 anecdote source : persona/cas spécifique doit matcher EXAMPLES claim ou avoir attribution explicite
- **Single-run P4** : strategist produit toute la plage en un run. Plus de `status='outline'` dans le calendar.
- **`promote-content-batcher` skill DELETED** (folded into strategist).
- **Operator-consultations** : nouveau champ `must_quote_from` listant les claim_ids STRUCTURE/EXAMPLES qu'un pillar doit grounding.

Si tu invoquais `/promote:promote-content-batcher` (v1.1+ workflow), ça n'existe plus. Le strategist gère tout.

## Install

### Mode 1 — Plugin Claude Code (production, recommandé)

```bash
/plugin marketplace add kalaspace/promote
/plugin install promote@promote-marketplace
/reload-plugins
# invocation : /promote:promote-strategist <url>
```

Mise à jour vers v1.4.0 si déjà installé en v1.3.0 :

```bash
/plugin marketplace update promote-marketplace
/plugin update promote
/reload-plugins
```

### Mode 2 — Multi-agent (Cursor / Codex / Gemini en plus de Claude Code)

```bash
npx skills add kalaspace/promote -g
# copie le seul skill exposé dans ~/.claude/skills/, ~/.cursor/, ~/.codex/, ~/.gemini/
```

### Mode 3 — Dev local (contribute / fork)

```bash
git clone https://github.com/kalaspace/promote
cd promote
./install.sh    # crée 1 symlink .claude/skills/promote-strategist → ../../skills/
# invocation : /promote-strategist <url>  (scope projet, depuis ce repo)
```

## Workflow utilisateur v1.4.0

1. `/promote:promote-strategist <url>` depuis le dossier de ton produit (ou avec `--days 30` pour limiter à 30 jours, ou `--rumelt-aval` pour activer le validator final opt-in).
2. Le strategist crawl + détecte le `product_type` (book/saas/course/service/hybrid).
3. **P0.5 — Le strategist demande le contenu structuré du produit** :
   - Pour un livre : *"Colle ta TOC complète + 2-5 lignes par chapitre."*
   - Pour un SaaS : crawl auto de docs/features/pricing.
   - Pour un cours : *"Colle le syllabus + objectifs par module."*
   - Pour un service : *"Colle ton offre détaillée + cas clients publics."*
   - Sortie : `intake/product-content.md`.
4. P1 — Le strategist pose les 5 batches de questions sur l'AUTEUR/ICP/marché/voix (pas la TOC, c'est P0.5).
5. P1.5 — Le strategist génère `intake/verified-claims.csv` avec ~40-80 claims (PRODUCT/PROCESS/AUTHOR/MARKET/FUTURE_HYPOTHESIS depuis batches + STRUCTURE/EXAMPLES depuis product-content.md). Tu reviews en ~20 min.
6. P2 — Recherche marché.
7. P3 — Stratégie synthesis (5 sub-phases avec must_quote_from sur chaque pillar promotionnel).
8. **P4 — Single-run** : le strategist produit tous les posts de la plage configurée (default 90 jours = ~90-270 posts selon cadence) en un run (~10-30 min wall-clock).
9. Tu reçois les posts concrets dans `content/posts/{slug}.md` (pur contenu prêt à coller, plus de placeholders) + metadata complète dans `.meta/{slug}.yaml`.

## Configuration runtime

Le strategist écrit ses artefacts (campagnes) selon cette hiérarchie de résolution :

1. **`$PROMOTE_HOME`** env var (override absolu) — `export PROMOTE_HOME=/path/to/store`.
2. **`./campaigns/`** relatif au cwd (défaut). Recommandé : tu lances `/promote-strategist <url>` depuis le dossier de ton produit/projet, les artefacts y sont écrits, versionnables avec git.
3. **`${CLAUDE_PLUGIN_DATA}/campaigns/`** fallback si cwd non-writable.

## Architecture v1.4.0

```
.claude-plugin/
├── marketplace.json
└── plugin.json

skills/                          # 1 entry point exposé (v1.4.0)
└── promote-strategist/          # pipeline complet URL → strategy + N-day full-window concrete

prompts/                         # 38 internal expert prompts (NON-skills, lus via Read+Task)
├── operators/                   # 16 operators (Welsh, McGarry, Faris, Wilcox, ...)
├── orchestrators/               # 1 (channel-strategist)
├── personas/                    # 9 (Hormozi, Schwartz, Holiday, Ammar, PG, X-Mastery,
│                                #     MrBeast, Steve Jobs, Gerhardt-Founder)
├── frameworks/                  # 8 (JTBD, Dunford, Cialdini, Voss, Four-Fits,
│                                #     PLG, GEO, AI-Content)
├── tactical/                    # 2 (customer-research, pricing-strategy)
└── utility/                     # 4 (huashu-nuwa, claims-extractor, fact-checker,
                                 #    reader-honesty-judge, product-content-ingester NEW v1.4.0)

references/                      # 22 validateurs canoniques (Rumelt, North Star,
│                                #   psychology-canon, sales-canon, demand-gen,
│                                #   attribution-canon, content-production,
│                                #   anti-fabrication-contract, claims-ledger-spec, ...)

campaigns/{slug}/                # runtime par campagne (gitignored)
├── STATE.yaml
├── intake/
│   ├── url-crawl.md
│   ├── product-content.md       ← NEW v1.4.0 (source-of-truth pour STRUCTURE+EXAMPLES)
│   ├── batch-{1..5}-*.md
│   ├── verified-claims.csv      ← v1.3.0 + STRUCTURE/EXAMPLES from product-content.md
│   └── never-claims.txt         ← v1.3.0 + v1.4.0 default entries
├── research/                    # market + ICP
├── strategy/
│   ├── 00-product-brief.md
│   ├── 02-jtbd-switch.md → 08-channel-strategy.md
│   ├── 10-tripwires-top3.md
│   ├── 11-content-calendar-Nd-full.csv  ← RENAMED v1.4.0 (full window, no outline)
│   ├── strategy-summary.md
│   ├── handoff-to-executor.yaml ← v1.4.0 schema
│   └── operator-consultations/  # consultations strategic + must_quote_from v1.4.0
└── content/
    ├── posts/
    │   ├── {slug}.md            ← PURE CONTENT prêt-à-coller
    │   └── .meta/{slug}.yaml    ← METADATA complète (8 quality gates audit)
    └── batch-reports/
```

**Files NOT generated by default v1.4.0** (vs v1.3.0) :
- `strategy/09-geo-plan.md` — CUT (defer to standalone `promote-geo-strategist` v1.4.1+)
- `strategy/p3f-rumelt-aval.md` — opt-in via flag `--rumelt-aval`
- `skills/promote-content-batcher/` — DELETED, folded into strategist single-run.

## Statut

- **Phases 0-5 (v1.0.0)** : DONE.
- **Phase 7 (v1.1.0)** : DONE. Two-pass orchestration + 17 operators + content-batcher.
- **Phase 8 (v1.2.0)** : DONE. Hide internal skills (2 exposés, 37 internes via Read+Task).
- **Phase 9 (v1.3.0)** : DONE. Quality + Verification + Lean (ledger + gates #7+#8 + schema split + trim P3).
- **Phase 10 (v1.4.0)** : DONE. Source-Truth Ledger + Single-Run.
- **Phase 6 (executor)** : à venir, post-v1.4.0. Posting réel via MCPs + cron + analytics.

## Plan complet

Voir `/home/kala/.claude/plans/le-but-est-nifty-creek.md`.

## Licence

MIT (orchestration, references, templates, distillations originales). Les prompts importés depuis des repos publics conservent leurs licenses (MIT pour wondelai, coreyhaines). Voir `docs/attributions.md` et `_ATTRIBUTIONS.md` dans chaque dossier de prompt.
