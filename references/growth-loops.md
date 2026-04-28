# Growth Loops — Reforge

> **Source canonique** : Brian Balfour (Reforge essays, 2017+) ; Kevin Kwok, *The Arc of Collaboration* ; Reforge curriculum 2017-2025.
> **Rôle dans le projet** : Catalogue des loops canoniques. Consulté par `promote-growth-four-fits` et par `promote-strategist` en P3 (étape `g`). **Un funnel sans loop = ce n'est pas une stratégie de croissance.**

---

## Funnel vs Loop : la différence fondamentale

### Le funnel (la vieille grammaire)

```
Acquisition → Activation → Retention → Revenue → Referral
```

Linéaire. Chaque étape consomme l'étape précédente. Le funnel **perd** de la valeur à chaque étape (taux de conversion < 100%). Pour faire tourner un funnel : injecter du carburant frais en haut. **Brûle du cash**.

### Le loop (la nouvelle grammaire)

```
       output
         ↓
[input]  →  [process]  →  [output reinvested as input]
```

L'output d'une action devient l'input d'une nouvelle action. Le loop **renforce** la valeur à chaque tour. Empilable.

> *"Funnels grow linearly with the resources you put into them. Loops grow exponentially with the engagement they create."* — Brian Balfour

---

## Catalogue des 7 loops canoniques

### 1. Content/SEO Loop

```
Users → User-generated content (or product data) → Indexed by Google → Free organic traffic → New users → ...
```

**Exemples** : Yelp (reviews → SEO → new users → more reviews), Pinterest (pins → SEO → new pinners), G2 (reviews → SEO → buyers → reviews).
**Quand c'est un bon fit** : produit avec data ou UGC indexable + intent search significatif.
**Investissement** : SEO + structure data + incentives à contribuer.
**Tueur 2026** : LLM-search compétiteur du SEO classique → coupler avec GEO (cf. `promote-geo-optimization`).

### 2. Viral Loop (organic invite)

```
User → Invites friend (in-product mechanic) → Friend joins → New user invites friend → ...
```

**Exemples** : Dropbox (storage for invite), Calendly (invitee receives URL → discovers Calendly), Zoom (meeting host invites guest who needs to install).
**K-factor** : nb d'invites par user × taux d'acceptation. Loop tient si K > 1.
**Quand c'est un bon fit** : produit qui **nécessite** ou **bénéficie naturellement** d'inviter quelqu'un (collaboration, partage, communication).

### 3. Paid Loop (LTV > CAC)

```
Acquisition payante → Revenue → Profit margin → Reinvested in paid acquisition → ...
```

**Tient si** : LTV > CAC × (1 + payback period en mois ÷ 12), avec payback < 12 mois en B2B SaaS, < 3 mois en consumer.
**Investissement** : maîtrise des canaux paid (Google, Meta, LinkedIn).
**Risque** : dépendance à un canal. Si CAC monte, le loop se brise.

### 4. UGC Loop (user-generated content)

```
User creates content on platform → Content attracts more users → New creators → ...
```

**Exemples** : YouTube, TikTok, Reddit, Substack, X.
**Différent de Content/SEO Loop** : les nouveaux users viennent **directement de la consommation du contenu**, pas seulement du référencement.
**Quand c'est un bon fit** : marketplace creators × consumers, ou plateforme sociale.

### 5. Sales-Assist Loop (B2B)

```
Inbound demand → SDR/AE qualifies → Closes deal → Customer success → Expansion + Referral → ...
```

**Pas un PLG-pur** : combine product-led acquisition avec sales-assist conversion. Reforge appelle ça "PLG2.0".
**Quand c'est un bon fit** : B2B avec ACV > $5K, complexité d'achat, multi-stakeholder.
**Anti-pattern** : forcer un PLG-only sur un produit qui nécessite du sales-assist (cf. `promote-plg-design`).

### 6. Network Effects Loop

```
Each new user → Increases value for ALL existing users → Drives more retention + referral → ...
```

**Différent du viral loop** : ici, la **valeur** augmente avec chaque user, pas juste l'invitation.
**Exemples** : LinkedIn, Slack (intra-company network), marketplaces.
**Référence** : voir `./network-effects.md` (Cold Start Problem, Andrew Chen).

### 7. Integration/Ecosystem Loop

```
Product integrated with X → Users of X discover product → Some adopt → New integrations built → ...
```

**Exemples** : Stripe (integrated by every B2B SaaS → discovered by their devs → some build their own product on Stripe), Zapier, Salesforce AppExchange.
**Quand c'est un bon fit** : produit qui devient un **composant d'autre chose**.

---

## Conditions de viabilité d'un loop

Un loop ne fonctionne que si :

1. **Cycle time < tolerable** : le tour du loop doit boucler en un temps acceptable. Un loop qui prend 18 mois pour boucler dans un marché qui évolue tous les 6 mois est mort-né.
2. **Unit economics positifs** : le loop doit générer plus qu'il ne consomme (en cash, en attention, ou en data).
3. **Defensibility** : un concurrent peut-il copier le loop trivialement ? Si oui, le loop ne dure pas.
4. **Scalability** : le loop continue de tourner quand le volume × 100 ?

---

## Application dans le pipeline

### Dans `promote-growth-four-fits` (Phase 2 framework)

Auditer le produit sur les 4 fits :
- Market/Product fit
- Product/Channel fit
- Channel/Model fit
- Model/Market fit

**Et identifier le loop dominant** parmi les 7 ci-dessus. Si aucun loop dominant n'émerge → marquer comme `growth_via_funnel_only` (alarmant).

### Dans `promote-strategist` P3 étape `g`

Le strategist consulte ce fichier après l'invocation de `promote-growth-four-fits` pour produire `strategy/05-growth-fits.md`. Le contenu doit nommer **le loop primaire** retenu, **un loop secondaire** éventuel, et **les 3-5 actions** qui activent ce loop.

Output structuré :

```markdown
## Primary growth loop

- **Loop type** : [content-seo | viral | paid | ugc | sales-assist | network-effects | integration]
- **Cycle time estimate** : [days/weeks]
- **Unit economics** : [LTV/CAC ou équivalent qualitatif]
- **Defensibility** : [strong | medium | weak]
- **3-5 actions to activate** : [...]

## Secondary loop (optional)

[idem ou "none"]
```

---

## Anti-patterns à signaler

- **"All channels at once"** : sans loop primaire identifié, tester 5 canaux en parallèle = brûler du temps et apprendre rien.
- **Confusion viral ≠ network effects** : viral = invite. NE = la valeur augmente avec users. Pas la même chose.
- **PLG dogmatic loop** : forcer un loop produit-only sur un B2B qui a besoin de sales-assist. Cf. `promote-plg-design`.

---

## Citations utiles

> *"Growth strategy isn't about doing more things. It's about choosing the loop that compounds and starving everything else."* — Brian Balfour

> *"If you're optimizing a funnel, you're losing to a competitor who's building a loop."*

> *"Most growth experiments fail because the team can't articulate which loop they're trying to amplify."*
