# Demand Generation — Refine Labs / Chris Walker

> **Sources canoniques** : Chris Walker / Refine Labs (devenu Passetto en 2024). Corpus de podcasts *State of Demand Gen* / *Revenue Vitals* (2020-2025). Pas un livre canonique mais l'école dominante de la GTM B2B mature 2021-2025.
> **Rôle dans le projet** : référence consultée par `promote-strategist` en P3 étape `m`. Détermine **quoi mesurer** et **où dépenser** quand le goal inclut leads/sales B2B. Couplé à `attribution-canon.md` pour les pièges de mesure.

---

## La distinction fondamentale

> *"Demand creation is when you build awareness, mindshare, and intent BEFORE the buyer is in-market. Demand capture is when you optimize for buyers who are already searching for a solution."* — Chris Walker

| | **Demand Creation** | **Demand Capture** |
|---|---|---|
| **Cible** | Le 95% qui n'est PAS in-market aujourd'hui. | Le 5% qui est in-market aujourd'hui. |
| **Canaux** | LinkedIn organic, podcasts, communautés, founder posts, contenu missionnaire, événements, dark social. | Google Ads, SEO, capterra/G2, retargeting, intent data (6sense, Bombora). |
| **Mesure** | Brand search lift, direct traffic, self-reported attribution, deal velocity. | Last-click attribution, CPL, MQL volume. |
| **Horizon** | 6-18 mois pour ROI. | Same week. |
| **Risque** | Difficile à attribuer last-click → blâmé par les CFO. | Sature, CPL monte, CAC explose. |

---

## L'erreur GTM B2B 2010-2020

Toute l'industrie a optimisé sur **demand capture only** (last-click attribution, CPL low, MQL volume) parce que c'était mesurable. Conséquences observées :
- Saturation des canaux paid (CPL ×3 en 5 ans).
- "MQL factory" → leads sales-rejected en masse → hostilité marketing/sales.
- Aucun différenciateur durable entre concurrents qui font tous les mêmes ads.

> *"You can't grow your way out of a category by competing for the 5% in-market. You grow by creating demand among the 95% not yet in-market."*

---

## Le shift Demand Gen 2021-2026

### Principe

Investir 70-80% du budget marketing en **demand creation** (contenu, podcast, communauté, founder content). Investir 20-30% en **demand capture** (Google, retargeting) pour récolter ce que la création a semé.

### Conséquences mesurage

- Les conversions remontent à **direct traffic** ou **branded search**, pas aux canaux paid.
- Donc le **last-click attribution sous-estime massivement** les canaux de création.
- Solution : **self-reported attribution** ("How did you hear about us?") + **multi-touch modeling**.

Voir `./attribution-canon.md` pour les outils.

### Conséquences contenu

- **Founder content** > brand content (les humains font confiance aux humains).
- **Provocative POV** > best-practices benchmarking (le contenu zéro-risque est zéro-impact).
- **Distribution > création** : un bon post lu par 100 personnes a moins de valeur qu'un post moyen lu par 50,000 dans la bonne audience.
- **Podcasts** comme canal de demand creation : 30-60 min d'attention concentrée, le format le plus dense en intent.

---

## Le "Dark Funnel"

> *"The buyer journey is invisible to your CRM. They consume podcasts, lurk in Slack communities, read LinkedIn comments, ask peers — for 6-18 months. Then they show up on your website typing your brand name."* — Walker

Implications :
1. La majorité des conversions B2B sérieuses arrivent **directement** ou via **branded search**.
2. Les rapports d'attribution last-click sont **trompeurs** — ils créditent Google ou retargeting alors que la vraie cause est un podcast écouté 4 mois plus tôt.
3. **Self-reported attribution** est la moins mauvaise des solutions pour comprendre ce qui marche vraiment.

---

## Application dans `promote-strategist`

Si `STATE.yaml.goal` est `leads` ou `sales` B2B :

### Étape : split du budget recommandé

Dans `strategy/06-distribution-plan.md` :

```markdown
## Demand Creation vs Demand Capture split

- **Recommended budget split** : [70/30 ou 80/20 demand creation]
- **Demand creation channels** :
  - Founder content on [LinkedIn|X|both]
  - Podcast strategy : [host or guest, target shows]
  - Community presence : [Slack groups, subreddits]
  - Long-form content : [POV essays, controversial takes]
- **Demand capture channels** :
  - Branded search SEM : [budget guardrail]
  - SEO for high-intent keywords : [list 5]
  - Capterra/G2 listing optimization : [yes/no]
  - Retargeting : [tier, budget cap]

## Why this split

- 95% of buyers are NOT in-market today (Walker / Refine Labs).
- Last-click attribution will blame paid channels and credit demand creation invisibly — so we instrument self-reported attribution (cf. attribution-canon.md).
```

### Anti-pattern à signaler

Si l'utilisateur (ou le crawl P0) montre que la majorité du budget marketing actuel est en **paid demand capture** (Google Ads + retargeting + intent data), marquer `demand_capture_overweighted` dans le STATE et le flagger en `strategy-summary.md`. Recommander un re-balance progressif (pas brutal — la demand creation prend 6-18 mois pour livrer).

---

## Pour produits B2C

La logique est partiellement transférable mais moins extrême : le ratio in-market vs not-in-market est plus haut en B2C (impulsion, prix bas, cycle court). Pour un B2C, le split peut être plus 50/50 ou même 30/70 demand-creation/capture selon catégorie.

---

## Citations utiles

> *"You can't optimize the funnel out of bad demand."*

> *"Marketing's job isn't to generate leads. It's to generate demand. Leads are a byproduct."*

> *"If your CFO asks 'what's our ROAS on LinkedIn organic,' the right answer is 'wrong question.' The right metric is pipeline velocity and brand search lift over a 6-month rolling window."*

> *"In 2026, the B2B companies winning are those whose founder is the chief marketing voice."*
