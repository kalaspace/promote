# Network Effects — Cold Start Problem (Andrew Chen)

> **Source canonique** : Andrew Chen, *The Cold Start Problem* (HarperBusiness, 2021).
> **Rôle dans le projet** : référence **conditionnelle**. Activée par `promote-strategist` SEULEMENT si le produit a un network-effect candidate (multi-side, marketplace, communauté, intégration). Pour un SaaS pur sans network effects, ce document est skipé.

---

## Quand ce doc s'applique

Le strategist détecte un network-effect candidate si l'une des conditions suivantes est vraie :
- Le produit a **deux côtés** (acheteurs/vendeurs, créateurs/consommateurs, employeurs/candidats).
- La **valeur d'utilisation augmente avec chaque nouvel utilisateur** (Slack intra-company, LinkedIn professionnel).
- Le produit a une **dimension communauté** (Discord-like, forum-like).
- Le produit est une **plateforme d'intégration** (Stripe, Zapier).

Sinon, **skip ce doc** et concentrer la stratégie sur les loops non-network (content, paid, sales-assist).

---

## Les 5 stades du Cold Start

### Stade 1 — The Cold Start Problem

Le produit est lancé, **personne ne l'utilise**. La valeur est zéro car il n'y a personne avec qui interagir.

**Stratégie typique** :
- **Single-player mode** : faire que le produit soit utile **seul**, sans network. (Slack en single-team. Pinterest pour un seul user.) Permet d'amorcer.
- **Atomic network** : la plus petite unité où le produit fonctionne (un département, une ville, un sous-marché). Concentrer toute l'énergie pour la saturer.
- **Hard side first** : si le produit a deux côtés (créateurs/consommateurs), commencer par le **côté le plus difficile** (les créateurs sont plus dur à acquérir que les consommateurs).

**Erreur courante** : essayer de lancer "globalement" avec un produit dilué. Mieux vaut être ultra-fort dans 1 niche que faible partout.

### Stade 2 — Tipping Point

L'atomic network commence à fonctionner. Les early adopters utilisent. Le produit gagne sa première traction.

**Indicateur** : retention organique > 30-40% à J7 dans la niche cible.

### Stade 3 — Escape Velocity

Le réseau s'étend au-delà de la niche initiale. Croissance non-linéaire. Effets de réseau visibles : chaque nouvel utilisateur augmente la valeur.

**Indicateur** : la croissance vient de **referrals organiques** plus que de paid acquisition.

### Stade 4 — Hitting the Ceiling

Saturation. La croissance ralentit. Le marché initial est colonisé.

**Stratégies** :
- Expansion vers nouveaux segments (vertical, géographique, démographique).
- Nouvelles features qui élargissent le use case.

### Stade 5 — Moat

Network effects deviennent un fossé concurrentiel. Difficile pour les concurrents d'atteindre la masse critique de votre côté.

---

## Les 4 types de network effects

| Type | Comment ça marche | Exemple |
|---|---|---|
| **Direct (same-side)** | Plus d'utilisateurs du même type → plus de valeur. | Slack (plus de collègues = plus utile), Telegram. |
| **Two-sided (cross-side)** | Plus d'un côté → plus de valeur pour l'autre côté. | Airbnb (plus d'hôtes = plus de choix pour voyageurs et inversement). |
| **Data network effects** | Plus d'utilisateurs → plus de data → meilleur produit. | Waze (plus de conducteurs = trafic plus précis). |
| **Tech / integration** | Plus de tiers intègrent → plus de valeur. | Stripe (plus d'apps utilisent Stripe = plus d'écosystème). |

---

## Le "hard side" et le "easy side"

Dans un network à deux côtés, l'un des deux est toujours le hard side (le plus dur à acquérir). Identification :

- **Marketplace** : les **vendeurs** sont souvent le hard side (offrir plus dur que demander).
- **Content platform** : les **créateurs** sont le hard side.
- **Dating** : un genre est généralement le hard side selon la niche.
- **B2B integration** : les **développeurs** qui intègrent sont le hard side.

**Stratégie hard-side-first** : suracquérir le hard side. Subventionner si nécessaire (Uber qui payait les chauffeurs avant d'avoir des passagers ; OnlyFans qui partage 80/20 en faveur des creators).

---

## Application dans `promote-strategist`

Si network-effect candidate détecté en P0/P1 :

### Étape : positionner le produit dans le Cold Start

Dans `strategy/05-growth-fits.md` (étape `g` du pipeline) :

```markdown
## Network Effects analysis

- **Network effect type** : [direct / two-sided / data / tech-integration]
- **Hard side** : [decided side] — pourquoi : [...]
- **Easy side** : [other side]
- **Atomic network** : [smallest unit where product works] — concrete : [department / city / sub-market]
- **Current stage** : [cold-start / tipping / escape / ceiling / moat]
- **Single-player mode value** : [yes/no — is the product useful with 0 other users?]

## Stage-specific strategy

[Si cold-start :]
- Choisir 1 atomic network. Saturer avant tout.
- Acquérir le hard side d'abord. Subventionner si besoin.
- Single-player mode = priorité produit, pas marketing.

[Si tipping point :]
- Doubler les efforts sur la niche qui marche.
- Ne PAS étendre prématurément.

[Si escape velocity :]
- Activer les loops de virality (referral programs).
- Identifier les features qui amplifient les network effects.

[Si ceiling :]
- Plan d'expansion vers segments adjacents.
- Nouveau cold start sur le segment d'expansion (récursion du framework).
```

---

## Anti-patterns

- **Lancer global avant atomic network saturé** : effort dilué, network effects ne s'amorcent pas.
- **Subventionner le easy side** : gaspillage. Le easy side viendra naturellement quand le hard side est là.
- **Mesurer les "users totaux" comme NSM** : un user dans une zone non-saturée vaut moins qu'un user dans une zone saturée. Mesurer **density per atomic network** est plus juste.
- **Confondre virality (invitation) et network effects (valeur croissante avec users)** : ce sont deux mécanismes différents (cf. `growth-loops.md`).

---

## Citations utiles

> *"In the cold start, the product is not the issue. The issue is that no one is there yet."* — Andrew Chen

> *"The hard side will tell you exactly what to build. The easy side will follow."*

> *"Density beats reach. A saturated dense network is exponentially more valuable than a sparse global one."*
