# Anti-Fabrication Contract (v1.4.0)

> **Rôle dans le projet** : section factorisée injectée par référence dans tous les `prompts/operators/*/prompt.md`, `prompts/personas/*/prompt.md`, `prompts/frameworks/*/prompt.md` et `prompts/orchestrators/*/prompt.md`. Définit deux invariants :
>
> 1. **No invented facts** (v1.3.0) : pas de fabrication factuelle hors ledger.
> 2. **Product-promotion constraint** (v1.4.0 NEW) : un post promotionnel doit être grounded dans le contenu du produit lui-même, pas raconter une story adjacente.
>
> **Pourquoi v1.3.0 anti-fabrication contract existe** : test v1.2.0 montrait ~30-40% de claims non-sourcées (ex : Substack inventait "6 mois de brouillons humains" alors que l'auteur n'a jamais tenté d'écrire sans IA).
>
> **Pourquoi v1.4.0 product-promotion constraint** : test v1.3.0 a montré que les Quality Gates #7+#8 fonctionnent (zéro fabrication évidente type "6 mois sans IA"), MAIS le ledger lui-même contenait des claims STRUCTURE inférés depuis batches d'interview ("chapitre prospection" sans confirmation TOC), et `operator-consultations/robinson-outbound.md` proposait *"chapitre 3 de mon livre"* — fabrication latente. Insight : **le produit lui-même** doit être la source de vérité primaire, pas l'intake interview. v1.4.0 ingère product-content.md en P0.5 et exige que les posts promotionnels soient grounded.

---

## Le contrat (à respecter par tout subagent operator/persona)

Tu opères sous **contrainte verified-claims**. Le strategist ou le content-batcher t'appellera avec un contexte qui inclut, pour chaque campagne :

- `intake/verified-claims.csv` — la liste des claims factuels validés par l'utilisateur (claim_id, claim_text, source_quote, category).
- `intake/never-claims.txt` — la liste des affirmations que l'utilisateur récuse explicitement (jamais à reproduire).

Tu DOIS respecter les 4 règles ci-dessous. Tout post (et toute consultation strategic) qui les viole sera rejeté par la Quality Gate #7 (factual claims check) et retourné en `manual_review_needed`.

### Règle 1 — Ne jamais inventer un détail de processus absent du ledger

Sont **strictement interdits** :

- Toute durée biographique non sourcée : *"X mois sans IA"*, *"depuis 2018"*, *"après 5 ans de chez Y"*, *"j'ai testé Z pendant 3 semaines"* — si pas dans le ledger, INTERDIT.
- Tout chiffre de processus non sourcé : *"180 pages de brouillon"*, *"12 chapitres jetés"*, *"50 prompts testés"* — si pas dans le ledger, INTERDIT.
- Toute scène sensorielle reconstruite : *"un samedi matin de novembre, café froid"*, *"dimanche soir face à l'écran"*, *"le post-it jaune sur le bureau"* — si pas dans le ledger ou pas explicitement attribuée, INTERDIT.
- Toute étape narrative que le ledger ne confirme pas : *"j'ai d'abord essayé X, puis pivoté"*, *"j'ai cru que Y, puis j'ai compris Z"* — l'arc psychologique requiert une trace dans l'intake.

### Règle 2 — Toute claim factuelle doit être traçable à 1 des 3 sources

Pour qu'une affirmation factuelle puisse apparaître dans un post, elle doit relever d'une (et une seule) des 3 catégories :

(a) **Sourced** : elle correspond à un `claim_id` du ledger. Implicitement, le subagent peut citer librement.

(b) **Public verifiable** : c'est un fait public vérifiable (date d'entrée en vigueur d'une loi, statistique sectorielle citée par une source nommée, fonctionnalité documentée d'un outil concurrent). À utiliser avec hedge ou citation.
- Ex OK : *"L'AI Act article 4 entre en application le 2 août 2026."*
- Ex OK : *"Selon l'enquête INSEE 2024, 26% des PME françaises..."* (avec lien si possible).

(c) **Explicitly attributed** : la claim est marquée comme parole de l'auteur, sans reformulation par toi.
- Ex OK : *"FN raconte qu'il a écrit ce livre avec l'IA depuis le jour 1."*
- Ex INTERDIT : *"FN, après 6 mois d'essais sans IA..."* (la précision "6 mois sans IA" est ta fabrication, pas la sienne).

### Règle 3 — Si une claim te manque : `narrative_gaps_to_fill`, pas fabrication

Si ton draft a besoin d'un fait que tu n'as pas (date précise, chiffre, anecdote spécifique), tu DOIS :

1. **STOP** la production de cette section spécifique.
2. Mettre un placeholder explicite dans ton draft : `{verify: did the author have a pre-AI writing phase? if yes, duration?}`.
3. Lister ce gap dans la sortie structurée sous `narrative_gaps_to_fill`.

Le content-batcher passera ces placeholders au user avant publication. **Quality Gate #1 (form check) rejettera tout post qui contient encore un `{...}` placeholder à la livraison "concrete"**.

JAMAIS combler le gap par une invention plausible.

### Règle 4 — Match avec `never-claims.txt` = REJECT immédiat

Si un draft contient une formulation qui correspond (sémantiquement) à une entrée du `never-claims.txt`, le post est REJETÉ sans retry. Pas de variation, pas de reformulation. C'est une zone interdite définie par l'auteur.

---

## Anti-pattern de référence (à ne JAMAIS reproduire)

Le post Substack `2026-05-10-substack-pillar1-jai-essaye-sans-ia.md` produit en v1.2.0 contenait :

> *« Six mois. Douze chapitres. Cent quatre-vingts pages de brouillon. Un samedi matin de novembre 2025, café froid, je relisais et la prose était grise. (...) Elle n'a pas trouvé le post-it jaune... Ces ancrages viennent de carnets remplis à la main pendant deux ans. »*

**Ce passage cumule les violations** :
- Durée fabriquée (6 mois sans IA) → l'auteur n'a JAMAIS tenté d'écrire sans IA. Cf. intake batch-1 Q1.8 : *"J'ai utilisé l'IA pour générer ce livre"* dès le départ.
- Chiffres fabriqués (12 chapitres, 180 pages de brouillon).
- Scène sensorielle reconstruite (samedi matin novembre, café froid, prose grise).
- Détail biographique inventé (carnets papier remplis à la main pendant 2 ans).

Ces inventions sont arrivées parce que le prompt operator (Lenny-Substack en mode production) suggérait implicitement une narrative arc *"failure-pivot"* (essayé sans IA → ça a échoué → utilisation de l'IA), et le subagent a comblé les détails manquants par fabrication.

**v1.3.0** : ce passage aurait dû déclencher 3 gates :
1. `narrative_hypotheses` en P3.C consultation Lenny : "tried 6 months without AI" doit être listé en `requires_claim` non-confirmé → fallback "AI from day 0".
2. Subagent production refuse de fabriquer → liste dans `narrative_gaps_to_fill`.
3. Quality Gate #7 (factual claims check) cross-checke chaque claim contre le ledger → rejet du draft.

---

## Format d'output structuré (production mode)

Tout subagent operator/persona en mode production DOIT retourner :

```yaml
title: "{30-80 chars hook}"
body: |
  {full content, no {...} placeholders allowed if status='concrete'}
narrative_gaps_to_fill:
  - gap: "Did the author have a pre-AI writing phase?"
    needed_for: "Pillar #1 opening narrative"
    fallback_if_unconfirmed: "Reframe to 'AI from day 0' arc"
factual_claims_used:
  - claim_id: C002  # from verified-claims.csv
    where_in_post: "first paragraph"
  - public_fact: "AI Act art. 4 entry-into-force 2026-08-02"
    where_in_post: "section 'le compte à rebours'"
  - attributed: "FN says X"
    where_in_post: "anchor anecdote"
assets_specs: {...}
posting_metadata: {...}
```

Si `narrative_gaps_to_fill` est non-vide ET le slot est demandé en status='concrete' (pas en 'outline'), le post sort en `manual_review_needed` avec le draft + la liste des gaps présentés au user.

---

## Format d'output (consultation mode P3.C)

Tout subagent operator/persona en mode strategic-consultation DOIT retourner les 7 champs habituels (feasibility_score, strategic_recommendations, cadence_proposed, content_pillar_adjustments, prerequisites_or_blockers, anti_patterns, recommended_skip_or_defer) **PLUS** le champ nouveau :

```yaml
narrative_hypotheses:
  - hypothesis: "Story arc 'tried X months without IA then pivoted'"
    requires_claim: "Author had pre-AI human writing phase"
    user_confirmation: REQUIRED  # not in verified-claims.csv at consultation time
    fallback_if_unconfirmed: "Reframe as 'AI from day 0, here's the prompt-cuts methodology'"
```

Le `narrative_hypotheses` capture les angles narratifs que l'operator propose **et qui ne sont pas sourcés**. Si tous tes angles sont sourcés, retourne `narrative_hypotheses: []`.

Le strategist + le content-batcher liront ce champ avant production : tout angle marqué `user_confirmation: REQUIRED` doit être validé par le user OU l'operator doit basculer sur le fallback.

---

## Product-Promotion Constraint (v1.4.0 — NEW second invariant)

Chaque post produit pour promouvoir un produit (livre, SaaS, cours, service) DOIT être grounded dans le contenu réel du produit. Pas de "story adjacente" qui raconterait une expérience ou une anecdote sans rapport avec ce que le produit contient littéralement.

### Le contrat (en plus des 4 règles anti-fabrication)

Tu opères sous **double contrainte** :
- **Anti-fabrication** (4 règles ci-dessus, v1.3.0) : ne pas inventer de faits hors ledger.
- **Product-promotion grounding** (v1.4.0) : les posts qui promeuvent un produit doivent extraire / paraphraser / citer le contenu DU produit, pas raconter d'autres histoires.

### Règle 5 — Pour un post de category PRODUCT_PROMOTION, ≥1 claim STRUCTURE/EXAMPLES

Tout post produit pour promouvoir directement le produit (mention du livre, lien d'achat, "achetez maintenant", etc.) DOIT inclure ≥1 référence à :
- Un élément STRUCTURE du produit (chapitre, module, feature, section) — listé dans `verified-claims.csv` avec `category=STRUCTURE` (sourced from `intake/product-content.md`).
- OU un EXAMPLES du produit (cas, anecdote, persona, quote présent dans le produit) — listé avec `category=EXAMPLES` (sourced from `intake/product-content.md`).

Quality Gate #7.1 enforce. Si le post n'a aucun claim_id de category STRUCTURE/EXAMPLES → SOFT-FAIL with reason "post not grounded in product content — adjacent story not allowed".

**Exception** : posts de category INDUSTRY_PERSPECTIVE (thought-leadership sur le marché, sans appel à acheter) sont exempts. L'auteur peut commenter le marché sans citer son livre. Mais ces posts doivent être ÉTIQUETÉS explicitement INDUSTRY_PERSPECTIVE dans le calendar — pas une excuse pour faire passer un post promotionnel sans grounding.

### Règle 6 — Référence structurelle = STRUCTURE claim mandatory (hard fail)

Si tu mentionnes un "chapitre N", "section X", "module Y", "feature Z", titre de chapitre/module littéral, ou nom de feature dans le post :
- Match exact ou semantic avec un `claim_id` de `category=STRUCTURE` du ledger ? → OK.
- Sinon → REJECT_IMMEDIATE par Quality Gate #7.2 (no retry).

Examples interdits :
- *"comme je l'explique au chapitre 3"* sans claim_id STRUCTURE pour "chapitre 3".
- *"voir le module 4 du cours"* sans claim_id STRUCTURE pour "module 4".
- *"dans la section pricing"* sans claim_id STRUCTURE pour "section pricing".

Examples OK :
- *"voir le **Chapitre 3 — Comment chiffrer un projet IA** du livre"* (texte exact match d'un claim_id STRUCTURE).
- *"la feature **Bulk Edit** documentée dans /docs/features"* (match d'un claim_id STRUCTURE).

### Règle 7 — Anecdote spécifique = EXAMPLES claim ou attribution

Si tu racontes une anecdote spécifique (avec personnage nommé, scène concrète, dialogue, lieu) :
- Match avec un `claim_id` de `category=EXAMPLES` (l'anecdote est dans le produit) → OK.
- Match avec attribution explicite ("FN m'a raconté que...") + un `claim_id` de category PROCESS du batch interview qui le confirme → OK.
- Sinon → SOFT-FAIL via Quality Gate #7.3 (anecdote possiblement fabriquée, manual review).

Examples interdits :
- *"Imagine Pascal, dirigeant d'une PME de 50 personnes, qui se lève le matin..."* — Pascal n'est pas dans EXAMPLES claims du ledger (générique fabriqué).
- *"Une fois, un client m'a dit que..."* sans attribution explicite ni claim_id EXAMPLES.

Examples OK :
- *"Bruno l'usineur (cas du Chapter 5)..."* — match claim_id EXAMPLES "Bruno l'usineur".
- *"FN m'a raconté qu'un de ses clients..."* — attribution explicite + claim_id PROCESS confirmant.

### Format d'output enrichi v1.4.0

Production mode output schema déjà défini ci-dessus, avec `factual_claims_used` listant claim_ids ET leur category. Quality Gate #7 cross-check #7.1/#7.2/#7.3.

Consultation mode (P3.C) : nouveau champ `must_quote_from` au-dessus de `narrative_hypotheses` :

```yaml
strategic_recommendations:
  - rec: "Pillar #1 = méta-IA-écrit"
    sourced_claims: [C002]
must_quote_from:
  # claim_ids of category STRUCTURE/EXAMPLES that this pillar MUST be grounded in
  - claim_id: C031  # STRUCTURE — Chapter 3 title
  - claim_id: C047  # EXAMPLES — Bruno l'usineur case
narrative_hypotheses:
  - hypothesis: "..."
    requires_claim: "..."
    user_confirmation: REQUIRED
    fallback_if_unconfirmed: "..."
```

Si `must_quote_from` est vide pour un pillar promotionnel → le pillar est REJETÉ (signal qu'il n'est pas ancré dans le produit).

---

## Inclusion par référence dans les internal prompts

Chaque `prompts/{operators,personas,orchestrators,frameworks}/*/prompt.md` doit contenir, en début de section "Anti-patterns" ou en section dédiée juste avant, ce bloc :

```markdown
## Anti-Fabrication Contract + Product-Promotion Constraint (mandatory v1.4.0)

This skill operates under the project-wide contracts documented in
`references/anti-fabrication-contract.md`. Read that file before any consultation or
production task. The contracts define :

**Anti-fabrication (v1.3.0, 4 rules)** :
- No inventing process details
- Traceability via ledger / public-fact / attribution
- narrative_gaps_to_fill instead of fabrication
- never-claims.txt = reject

**Product-promotion constraint (v1.4.0, 3 rules)** :
- For PRODUCT_PROMOTION posts: ≥1 claim_id of category STRUCTURE/EXAMPLES required (Gate #7.1)
- Structural references (chapters/modules/features) must match a STRUCTURE claim (Gate #7.2)
- Specific anecdotes must trace to EXAMPLES or explicit attribution (Gate #7.3)

The Lenny-Substack v1.2.0 anti-pattern reference (6-mois-sans-IA fabrication) +
the v1.3.0 robinson-outbound "chapitre 3" fabrication are the canonical examples.

Output formats :
- Production : factual_claims_used (with category) + narrative_gaps_to_fill
- Consultation : must_quote_from (NEW v1.4.0) + narrative_hypotheses

Quality Gates #7 + #7.1/#7.2/#7.3 in `references/content-production.md` enforce.
```

---

## Changelog

- **0.2.0** (2026-05-01) — v1.4.0. Ajout du second invariant Product-Promotion Constraint (3 nouvelles règles — Règle 5/6/7). Ajout du champ `must_quote_from` en consultation mode. Inclusion par référence enrichie pour 34 prompts internal. Réponse au post-mortem v1.3.0 sur la même campagne livre qui a révélé que le ledger lui-même contenait des claims STRUCTURE inférés (fabrications latentes) et qu'un template DM proposait "chapitre 3" sans validation.
- **0.1.0** (2026-04-30) — Initial release for v1.3.0. Réponse au post-mortem v1.2.0 sur la campagne livre amazon-fr-dp-b0gx2zpnyq qui a révélé 30-40% de claims factuelles non-sourcées dans les posts produits.
