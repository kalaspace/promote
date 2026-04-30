# Claims Ledger Spec

> **Rôle dans le projet** : référence consultée par `promote-strategist` (P1.5 extraction + validation, P3 consumption) et `promote-content-batcher` (P4 fact-check). Documente le format CSV `verified-claims.csv` + le format texte `never-claims.txt` + le lifecycle (extraction → validation user → consumption gates).
>
> **Pourquoi ce ledger existe** : v1.2.0 n'avait aucun gate factuel. Les 6 quality gates v1.2.0 vérifient la forme (longueur, voix, anti-patterns) mais pas la substance. Résultat sur la campagne livre : ~30-40% des posts avec claim factuelle non-sourcée. v1.3.0 introduit un ledger des claims validés en P1.5 et 2 gates aval (Quality Gate #7 fact-check + #8 reader-honesty).

---

## Vue d'ensemble du lifecycle

```
P0 INTAKE (crawl URL)
  ↓
P1 PRODUCT DEEP DIVE (5 batches questions, user répond)
  ↓
P1.5 CLAIMS EXTRACTION & VALIDATION  ← NOUVEAU v1.3.0
  - Subagent claims-extractor lit intake/* + url-crawl
  - Output: intake/verified-claims.csv (auto-extracted)
  - Output: intake/never-claims.txt (squelette vide à remplir)
  - GATE HUMAIN (mode guided): user review en 15 min, valide/rejette/ajoute never-claims
  - GATE AUTOPILOT: marquer claims confidence=LOW comme `verified_by_user=FALSE`
  ↓
P2 MARKET RESEARCH (WebSearch — claims publics, pas user-specific)
  ↓
P3 STRATEGY SYNTHESIS (consume verified-claims.csv comme contrainte)
  - Strategist cite claim_id quand reformule un fait
  - Operator-consultations P3.C produisent `narrative_hypotheses` distincts
  ↓
P4 CONTENT PRODUCTION
  - Operator subagent reçoit verified-claims.csv + never-claims.txt en contexte
  - Subagent produit le post avec `factual_claims_used` listant les sources
  - Quality Gate #7 (fact-checker subagent) cross-checke chaque claim → reject si fail
  - Quality Gate #8 (reader-honesty judge) → reject si auto-promo > 50%
```

---

## Format `verified-claims.csv`

Localisation : `campaigns/{slug}/intake/verified-claims.csv`.

### Schéma colonnes

| Colonne | Type | Obligatoire | Description |
|---|---|---|---|
| `claim_id` | string `C\d{3,4}` | OUI | Identifiant unique stable (C001, C002, ...). Référencé par les posts via `factual_claims_used`. |
| `claim_text` | string | OUI | Affirmation reformulée concise, 1 phrase. Exemple : *"Le livre contient 15 cas Flex et 3 filtres."* |
| `source_batch` | enum `batch-1-product`, `batch-2-icp`, `batch-3-pricing`, `batch-4-proof`, `batch-5-voice-goals`, `url-crawl`, `NONE` | OUI | Quel artefact intake contient la source. `NONE` = pas trouvé (claim ajoutée par le user en review). |
| `source_quote` | string | OUI si `source_batch != NONE` | Citation textuelle exacte de l'intake qui prouve la claim. Doit pouvoir être copiée-collée dans Ctrl-F sur le batch source. |
| `category` | enum `PRODUCT`, `PROCESS`, `AUTHOR`, `MARKET`, `FUTURE_HYPOTHESIS` | OUI | Type de claim. Détaillé ci-dessous. |
| `confidence` | enum `HIGH`, `MEDIUM`, `LOW` | OUI | Confiance de l'extracteur LLM. HIGH = source quote littérale. MEDIUM = paraphrase fidèle. LOW = inférence. |
| `verified_by_user` | bool `TRUE`, `FALSE` | OUI | Validation manuelle. Auto-rempli `TRUE` pour confidence=HIGH en mode guided ; `FALSE` par défaut autrement. |
| `notes` | string | NON | Notes optionnelles user (nuances, edge cases, contre-exemples). |

### Catégories

- **`PRODUCT`** : caractéristiques objectives du produit. Ex : *"15 cas + 3 filtres"*, *"prix 9.99 EUR Kindle"*, *"format PDF + ePub"*, *"contenu en français"*.
- **`PROCESS`** : comment le produit a été créé. Ex : *"écrit avec l'IA"*, *"3 prompts principaux utilisés"*, *"révisé par lecteur beta"*. **CATÉGORIE LA PLUS SENSIBLE AUX HALLUCINATIONS** — c'est ici que les opérateurs inventent des arcs narratifs (cf. anti-fabrication-contract.md).
- **`AUTHOR`** : qui est l'auteur, biographie, expérience. Ex : *"François Neumann, dirigeant de PME tech"*, *"basé en France"*. Ne pas inventer crédits, années d'expérience, missions passées.
- **`MARKET`** : faits sur le marché ou les concurrents. Ex : *"Atlan se positionne en data observability"*. Souvent vérifiable publiquement — préférer Public Verifiable hedge en post plutôt que claim_id si le user n'a pas explicité.
- **`FUTURE_HYPOTHESIS`** : projections, objectifs, KPIs cibles. Ex : *"objectif 200 ventes Kindle en 90 jours"*. À utiliser en post UNIQUEMENT comme objectif déclaré, pas comme fait accompli.

### Exemple concret (extrait de la campagne livre)

```csv
claim_id,claim_text,source_batch,source_quote,category,confidence,verified_by_user,notes
C001,"Le livre contient 15 cas Flex et 3 filtres décisionnels",batch-1-product,"Q1.6: Le livre contient 15 cas Flex (situations réelles d'intégration IA) et 3 filtres pour décider quels projets méritent l'effort.",PRODUCT,HIGH,TRUE,
C002,"L'auteur a utilisé l'IA pour générer le livre depuis le départ",batch-1-product,"Q1.8: J'ai utilisé l'IA pour générer ce livre en réponse à mes interrogations concernant la difficulté d'intégration là où je travaille.",PROCESS,HIGH,TRUE,"Pivot pillar #1 = méta-IA-écrit"
C003,"Le livre vise les dirigeants de PME bloqués sur l'intégration IA",batch-2-icp,"Q2.1: ICP primaire = dirigeants/managers de PME 20-200 employés qui se demandent par où commencer avec l'IA.",PRODUCT,HIGH,TRUE,
C004,"Format Kindle à 9.99 EUR + version papier 17.90 EUR",url-crawl,"Amazon listing: Format Kindle 9,99 €. Format Broché 17,90 €.",PRODUCT,HIGH,TRUE,
C005,"AI Act article 4 entrera en vigueur 2026-08-02",batch-5-voice-goals,"Q5.4: La date du 2 août 2026 est l'entrée en application des sanctions article 4 AI Act.",MARKET,MEDIUM,TRUE,"Public verifiable — peut être cité directement comme fait public."
C006,"L'auteur a passé 6 mois à écrire sans IA avant de pivoter",NONE,,PROCESS,LOW,FALSE,"Extrait depuis strategy/04-offer-audit.md hooks. AUCUNE source intake. À rejeter en review user."
```

### Règles d'extraction (P1.5 subagent)

Le subagent `claims-extractor` doit :

1. Lire tous les fichiers `intake/batch-*.md` + `intake/url-crawl.md` + `00-product-brief.md` (si déjà généré).
2. Extraire chaque affirmation factuelle qui apparaît dans ces fichiers, **uniquement si elle est sourçable à un quote littéral**.
3. Reformuler en 1 phrase concise (claim_text), conserver le quote (source_quote).
4. Catégoriser (PRODUCT / PROCESS / AUTHOR / MARKET / FUTURE_HYPOTHESIS).
5. Confidence :
   - HIGH = paraphrase littérale d'1 phrase de l'intake
   - MEDIUM = synthèse de 2-3 phrases de l'intake
   - LOW = inférence ou extrapolation (à présenter au user pour validation)
6. NE PAS inventer de claim. Si pas de source claire → ne pas extraire.
7. Si une claim apparaît dans `00-product-brief.md` mais pas dans intake/batch-* → marquer `source_batch=NONE` + flag explicite. C'est un signal de fabrication strategist en P3 — à investiguer.

Output type : ~20-50 claims extraites par campagne pour un produit standard.

### Règles de validation user (gate humain mode guided)

Présentation au user :
```
Voici les 32 claims extraites de ton intake. Review en 15 min :
- Pour chaque claim, valide (TRUE) ou rejette (FALSE).
- Si une claim est inexacte, édite claim_text directement.
- Ajoute en bas les claims que l'extracteur a manquées.
- Liste en never-claims.txt les phrases que tu refuses qu'on dise sur ton produit.
```

User édite le CSV directement (Excel / texte). Lance ensuite le strategist en mode `--resume` qui repart de P2.

### Mode autopilot

- Skip le gate humain.
- Toutes les claims `confidence=HIGH` → auto-validate `verified_by_user=TRUE`.
- Toutes les claims `confidence=MEDIUM` ou `LOW` → `verified_by_user=FALSE` (ne seront pas utilisables comme sources confirmées en P4).
- `never-claims.txt` créé vide. User peut le remplir post-mortem si une hallucination apparaît.

---

## Format `never-claims.txt`

Localisation : `campaigns/{slug}/intake/never-claims.txt`.

Format : 1 affirmation par ligne, en langage naturel, formulée de manière à matcher sémantiquement les variations.

### Exemple

```
# Never-claims for {slug}
# Format: 1 forbidden claim per line. Comments start with #.
# These will REJECT_IMMEDIATE any post containing them (no retry).

# Process inventions
The author tried writing the book without AI for any duration before using AI.
The author had previous human-only manuscripts or drafts.
The author tested 6+ different AI tools before settling on the current method.
The author writes in any language other than French as primary.

# Bio inventions
The author has previously published other books.
The author has worked at GAFAM or any specific large tech company without source.
The author was a founder/CEO of any startup not mentioned in intake.

# Product inventions
The book contains video content or interactive exercises.
The book has paper editions other than the ones listed in url-crawl.
The book is part of a series or has sequels planned.
```

### Règles d'enforcement

Le subagent `fact-checker` (Quality Gate #7) reçoit le post draft + le contenu de `never-claims.txt`. Pour chaque ligne never-claim :

1. **Match sémantique** : utiliser un LLM-as-judge (le fact-checker lui-même) pour détecter si une variation du claim apparaît dans le draft. Pas un simple grep — variations linguistiques OK.
2. Si match → `reject_immediate: true` dans le rapport quality gate. Pas de retry. Le draft est jeté, le slot reste en `outline` avec note `manual_review_needed: matched never-claim "{X}"`.
3. Si pas de match → continuer avec les autres règles (Règle 2 traçabilité, Règle 3 narrative_gaps).

---

## Quality Gate #7 — Factual Claims Check (lifecycle)

Détaillée dans `references/content-production.md`. Synthèse :

```
INPUT: post draft (title + body) + verified-claims.csv + never-claims.txt + url-crawl.md
SUBAGENT: prompts/utility/fact-checker/prompt.md

PROCESSING:
1. Extraire chaque claim factuelle du post (statement sur produit/auteur/processus/chiffres).
2. Pour chaque claim:
   a. Match never-claims (sémantique) → REJECT_IMMEDIATE si match
   b. Match verified-claims (claim_id + variations) → OK
   c. Match Public Verifiable (url-crawl, faits publics datés/chiffrés avec marker) → OK
   d. Match Attributed (markers "FN raconte que...", "selon l'auteur...") → OK
   e. Sinon → UNVERIFIED claim
3. Si > 2 UNVERIFIED claims OU 1 REJECT_IMMEDIATE → fail.

OUTPUT (yaml):
{
  pass: true | false
  reject_immediate: bool  # never-claim match
  unverified_claims: [list of {claim_text, location_in_post}]
  factual_claims_traced: [list of {claim_in_post, source: claim_id|public_fact|attributed}]
  recommendation: "ship" | "retry_with_ledger_constraints" | "manual_review_needed"
}
```

---

## Estimation coût

- **P1.5 extraction** : ~5-10K tokens (1 subagent call sur ~5 batches markdown).
- **User validation** : 15 min temps utilisateur (pas de tokens).
- **P4 fact-check par post** : ~3-7K tokens (1 subagent call sur le draft + ledger).
- **14 posts × 5K** = ~70K tokens additionnels par campagne.

Compensé largement par les économies Phase 9.E (-105K tokens via trim P3 theater).

---

## Anti-patterns du ledger lui-même

- **Over-extraction** : extraire 100+ claims = ledger ingérable. Cap à ~30-50 claims par campagne. Si > 50, reformer en groupes ou en exclure les claims très évidentes.
- **Claims trop vagues** : *"Le produit est bien"* n'est pas une claim factuelle. Filtrer les opinions.
- **Confondre PRODUCT et FUTURE_HYPOTHESIS** : *"Le livre va devenir un best-seller"* = HYPOTHESIS, pas PRODUCT.
- **never-claims trop spécifiques** : *"6 mois et 12 chapitres"* = trop précis, ne matchera pas la variation *"plusieurs mois et une dizaine de chapitres"*. Préférer formulation sémantique large : *"any pre-AI writing phase of any duration"*.

---

## Changelog

- **0.1.0** (2026-04-30) — Initial release for v1.3.0. Réponse au post-mortem v1.2.0 (campagne livre amazon-fr-dp-b0gx2zpnyq) qui a montré 0 gate factuel et ~40% de claims non-sourcées. Ledger CSV + never-claims + Quality Gate #7 + #8 introduites.
