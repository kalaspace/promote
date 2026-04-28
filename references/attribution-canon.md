# Attribution Canon — Modern B2B Attribution

> **Sources canoniques** : SparkToro (Rand Fishkin) sur le dark social. Self-reported attribution études HockeyStack / Dreamdata / Common Room (2023-2025). Refine Labs / Chris Walker corpus podcast. Reforge curriculum.
> **Rôle dans le projet** : référence pour `promote-strategist` en P3 étape `m`. **Sans cette grille, le système optimise un fantôme.**

---

## Le problème : last-click ment

Last-click attribution = créditer 100% de la conversion au **dernier touchpoint** avant l'achat. Le standard de Google Analytics depuis 2005.

### Pourquoi ça ment en B2B 2026

> *"60-70% of B2B conversions come from channels that don't track. Slack DMs, podcasts, peer recommendations, lurker periods on LinkedIn comments. The CRM sees only the last 2 minutes of an 18-month decision."* — Common Room report 2024

Conséquences mesurées :
- Les podcasts sont **systématiquement sous-attribués** (l'auditeur Google la marque 4 mois plus tard et la conversion est créditée à "branded search" ou "direct").
- Les **founder posts LinkedIn organic** sont sous-attribués (les vues ne se trackent pas, les conversions arrivent en direct).
- Les **communautés Slack** sont totalement invisibles à GA.
- À l'inverse, **paid retargeting** est sur-attribué (récupère le crédit du dernier clic, alors que l'achat aurait eu lieu de toute façon).

---

## Les 4 modes d'attribution moderne

### 1. Last-click (standard, sous-estime massivement le top-of-funnel)

À utiliser **uniquement** pour comparer des canaux purement transactionnels (Google Ads vs Meta Ads). À ne PAS utiliser pour évaluer le ROI marketing global.

### 2. Multi-touch (linear, time-decay, U-shaped, W-shaped)

Distribue le crédit entre plusieurs touchpoints. Mieux que last-click mais limité par **la visibilité** : ne capture que les touchpoints trackables (UTM, cookies). Le dark social reste invisible.

### 3. Self-reported attribution

> *"How did you hear about us?"* dans le formulaire d'inscription / demo / inscription mailing-list.

| Pros | Cons |
|---|---|
| Capture le dark social (podcast, peer, Slack) | Bruit dans les réponses ("Google" = ils ont googlé après avoir entendu le nom quelque part) |
| Simple à implémenter (un champ formulaire) | Catégories à standardiser pour analyse |
| Coût zéro | Ne marche que sur la conversion finale |

**Best practice** : 5-7 catégories prédéfinies + champ libre. Catégories typiques : Podcast / LinkedIn / Twitter / Search / Friend / Community / Other.

### 4. Modeled attribution (HockeyStack / Dreamdata / Bizible)

Modèles statistiques qui combinent les 3 sources ci-dessus + signaux first-party. Coûteux ($$$/mois) mais c'est l'état de l'art enterprise B2B.

À recommander si ARR > $10M et budget marketing > $1M/an. En dessous, self-reported + multi-touch + intuition produit.

---

## Le triangle de mesure recommandé

Pour les budgets sub-enterprise, utiliser **3 sources triangulées** :

```
       Self-reported attribution (forms)
                    │
                    │
    Pipeline ──────┼──────── Multi-touch (UTMs)
    velocity        │        on captureable channels
                    │
            Branded search
            volume trend
            (Ahrefs/SEMrush)
```

**Lecture combinée** :
- Si self-reported dit "podcast" mais multi-touch dit "branded search," alors podcast → branded search (le user a googlé après le podcast).
- Si pipeline velocity augmente sans que multi-touch trouve un canal nouveau, c'est demand creation invisible (à célébrer, pas à craindre).
- Si branded search augmente, c'est le **leading indicator #1** que la création de demande fonctionne.

---

## Application dans `promote-strategist`

En P3 étape `m`, le strategist écrit dans `strategy/10-instrumentation.md` :

```markdown
## Attribution stack

### What we will track (and how)

| Channel | Last-click trackable? | Multi-touch trackable? | Best signal |
|---|---|---|---|
| Google search (paid) | ✓ | ✓ | Last-click |
| Google search (organic) | ✓ | ✓ | Last-click + branded vs non-branded |
| LinkedIn organic | ✗ | ✗ | Self-reported + branded search lift |
| LinkedIn ads | ✓ | ✓ | Last-click (but watch for under-attribution) |
| Podcasts | ✗ | ✗ | Self-reported only |
| Newsletter | partial | partial | UTMs + self-reported |
| Slack/community DMs | ✗ | ✗ | Self-reported |
| Direct traffic | ✓ | ✗ | Branded search proxy |

### Self-reported attribution mechanism

- Field on [signup form / demo form / newsletter form] : "How did you hear about us?"
- Categories : [list 5-7 from above table]
- Free-text "Other" allowed
- Frequency of analysis : [weekly | monthly]
- Owner : [marketing ops / founder]

### Branded search tracking

- Tool : [Ahrefs / SEMrush / Google Search Console]
- Baseline : [current monthly branded search volume]
- Target : [+X% in 90 days]

### Kill-switch on attribution drift

- If [primary KPI] drops by Y% over 4 consecutive weeks AND multi-touch attribution doesn't explain why → trigger pivot review (likely a demand creation channel has died invisibly).
```

---

## Anti-patterns

- **CFO-driven last-click only** : optimise pour le mesurable, tue le top-of-funnel invisible. Spirale d'attribution descendante.
- **Pas de self-reported** : aucune visibilité sur le dark social. Vol à l'aveugle pour les canaux non-trackables.
- **UTM partout sans discipline** : 87 sources différentes dans GA, aucune action possible.
- **Chercher la perfection d'attribution** : le perfect attribution n'existe pas en B2B. Mieux vaut une triangulation imparfaite qu'un modèle parfait illusoire.

---

## Citations utiles

> *"The job of attribution isn't to know exactly which dollar caused which sale. It's to know which channels to keep funding and which to cut."*

> *"Last-click is what you measure. Demand is what you build."* — Refine Labs paraphrased

> *"If you only fund what you can attribute, you've capped your growth at last-click ceiling."*
