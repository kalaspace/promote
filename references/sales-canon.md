# Sales Canon — SPIN + Challenger + JOLT

> **Sources canoniques** : Rackham, *SPIN Selling* (McGraw-Hill, 1988). Dixon & Adamson, *The Challenger Sale* (Portfolio, 2011), *The Challenger Customer* (2015), *The JOLT Effect* (2022). Voss, *Never Split the Difference* (2016) — couvert par le skill `promote-voss`.
> **Rôle dans le projet** : pour le **pitch** (sales pages, demo decks, founder pitches) et **objection handling**. Lecture par `promote-strategist` quand le goal est `leads` ou `sales` B2B. **Note clé 2026** : 40-60% des deals B2B sont perdus à *no decision*, pas à un concurrent. C'est le point central de JOLT.

---

## SPIN Selling (Rackham, 1988) — toujours pertinent

Basé sur 35,000 calls observés. Le seul framework B2B sales massivement empirique.

### Les 4 types de questions

1. **Situation questions** : faits sur la situation actuelle du prospect.
   - *"Quel système utilisez-vous actuellement pour X ?"*
   - **Risque** : trop de Situation questions = ennui. Préparer en amont via research, pas via questions.

2. **Problem questions** : difficultés, insatisfactions, problèmes implicites.
   - *"Quels problèmes rencontrez-vous avec votre système actuel ?"*
   - **But** : faire émerger la douleur que le prospect n'a peut-être pas encore verbalisée.

3. **Implication questions** : développe les conséquences du problème.
   - *"Si ce problème continue 6 mois, quel sera l'impact sur [team/revenue/risk] ?"*
   - **But** : transformer un problème implicite en problème explicite et urgent. C'est ICI que la valeur perçue augmente.

4. **Need-payoff questions** : invite le prospect à dire lui-même la valeur de la solution.
   - *"Si vous résolviez ce problème, qu'est-ce que ça changerait pour [équipe/business] ?"*
   - **But** : le prospect verbalise les bénéfices. Il se vend la solution lui-même.

### Le pattern

> *"Top performers ask 4-5x more Implication and Need-payoff questions than average performers."* — Rackham

Application en promo : les **landing pages B2B** qui posent des Implication questions (souvent en titre ou sub) convertissent mieux que celles qui listent juste les features.

---

## Challenger Sale (Dixon & Adamson, 2011)

### 5 profils de vendeur

Le Challenger profil bat les autres en complexe-sale (3-5x mieux). Ses caractéristiques :

| Action | Description |
|---|---|
| **Teach** | Enseigne au prospect quelque chose de nouveau sur **son propre business**. Pas sur ton produit. |
| **Tailor** | Adapte le message au contexte précis du prospect (industrie, rôle, taille). |
| **Take control** | Prend la conversation en main. Pousse les concessions. Refuse les pertes de temps. |

### Commercial Insight

> *"A great commercial insight is something the customer doesn't know about themselves but should — that has financial implications, and that you uniquely solve."*

Structure :
1. **Warmer** : pose un constat surprenant sur le marché ("Most companies in [industry] are losing X% to [hidden cost].")
2. **Reframe** : suggère que le problème réel n'est pas celui qu'ils pensent.
3. **Rational drowning** : avalanche de data prouvant le reframe.
4. **Emotional impact** : "Ça arrive aux concurrents, ça vous arrive aussi."
5. **A new way** : la nouvelle approche.
6. **Your solution** : ENFIN tu présentes le produit.

Application en promo : les **founder posts B2B** qui suivent cette structure (warmer → reframe → ...) convertissent en demos qualifiés.

---

## JOLT Effect (Dixon, 2022) — la mise à jour critique 2025-2026

> *"40-60% of qualified B2B deals are lost to NO DECISION, not to a competitor."* — Dixon

Le prospect ne choisit pas un concurrent. Il **n'achète personne**. Pourquoi ? **Decision indecision** — la peur de faire le mauvais choix. La peur de la critique interne. L'overload de research.

### Les 4 leviers JOLT

| Lever | Action | Concrètement |
|---|---|---|
| **J — Judge** | Évaluer le niveau d'indécision du prospect tôt. | Qualifier ("Quel est votre process de décision ?") plutôt que pousser. |
| **O — Offer** recommendation | Faire une **recommandation explicite**. Pas "voici 3 options," mais "je vous recommande X parce que Y." | Le prospect veut être guidé, pas confondre. |
| **L — Limit** exploration | Bloquer la spirale infinie de research. | "Voici ce qui compte. Tout le reste est noise. Ne le regardez pas." |
| **T — Take risk off the table** | Réduire le risque perçu. | Try-before-buy, pilote court, garantie, opt-out clair. |

> *"Stop trying to convince. Start trying to de-risk."* — Dixon

Application en promo : la **page de pricing** ou la **dernière email de séquence** doit appliquer JOLT — pas "buy now," mais "voici la recommandation pour votre cas + voici comment on retire le risque."

---

## Application dans `promote-strategist`

Si `STATE.yaml.goal == leads` ou `sales` ET `audience` est B2B :

### Dans P3 étape `c-d` (positioning + offer audit)

Construire la **Commercial Insight** : qu'est-ce que ce produit "enseigne" au prospect sur son propre business ? Si la réponse est *"aucune insight, c'est juste une feature better"*, marquer `weak_commercial_insight`.

### Dans P3 étape `j` (channel mix)

Pour les canaux B2B (LinkedIn, email, sales-assist), inclure dans `strategy/06-distribution-plan.md` :

```markdown
## Sales conversation framework

- **SPIN questions to ask in discovery** : [list 5-7]
- **Commercial Insight (3-step warmer → reframe → reveal)** : [...]
- **JOLT levers ready** :
  - Recommendation logic : [under what conditions, recommend product]
  - Exploration limiter : [the 3 criteria that matter, all others ignored]
  - Risk-off-table mechanism : [pilot / guarantee / try-before / ...]
```

---

## Anti-patterns

- **Pure Solution Selling (1990s)** sans insight : pose des questions, écoute, propose le produit. → Convertit moyennement en 2026, le prospect cherche un POV pas une enquête.
- **Pas de recommandation explicite** : *"Here are your options, you decide."* → le prospect tombe dans l'indecision JOLT.
- **Trop de features dans le pitch** : surcharge cognitive → no decision.
- **Garantie absente** : sans risk-off-table, le prospect demande "je vais y réfléchir."
- **SPIN appliqué froidement** : enchaîner Situation/Problem/Implication/Need-payoff comme une checklist transparente → effet inverse, le prospect se sent manipulé.

---

## Citations utiles

> *"Customers don't want a salesperson. They want a guide."* — Dixon, post-JOLT

> *"The biggest competitor of every B2B SaaS is not a competitor. It's the customer's calendar."* — Modern paraphrase

> *"Implication questions are where the deal is actually built. Need-payoff questions are where the customer convinces themselves."* — Rackham
