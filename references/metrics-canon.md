# Metrics Canon — North Star Framework

> **Source canonique** : Amplitude, *The North Star Playbook* (2019, mises à jour 2023+). Origine : Sean Ellis chez Dropbox, formalisé chez Amplitude.
> **Rôle dans le projet** : référence consultée par `promote-strategist` en P3 (étape `m` instrumentation) pour produire `strategy/10-instrumentation.md`. Tout choix de KPI passe par ce framework.

---

## La règle d'or

> *"Pick one North Star Metric (NSM) that captures the value your product delivers. Pick 3-5 input metrics that drive the NSM. Stop tracking everything else as primary."* — Amplitude

Une boîte qui suit 50 KPI suit zéro KPI. La discipline du North Star : choisir le **1** qui mesure la valeur, et les **3-5** qui le pilotent.

---

## NSM vs Revenue : la distinction critique

**Revenue est lagging**. Il ne te dit pas pourquoi les choses marchent ou ne marchent pas — il te dit ce qui s'est passé.

**NSM est leading** : c'est la **valeur** que les users tirent du produit, mesurée d'une manière qui prédit le revenue.

| Produit | NSM (good) | Pourquoi pas revenue |
|---|---|---|
| Spotify | Time spent listening | Si users écoutent, ils restent et upgradent. |
| Airbnb | Nights booked | Mesure la valeur consommée par les voyageurs ET la valeur livrée par les hôtes. |
| Slack | Messages sent in workspace | Mesure l'adoption réelle (pas juste les seats). |
| Substack | Active paid subscribers | Compte les users qui valident la valeur par leur portefeuille. |
| Promotion produit (notre cas) | Selon le goal : conversions attribuées | Le revenue de l'utilisateur est out-of-scope ; on mesure ce qu'on contrôle. |

---

## Critères d'un bon NSM

1. **Capture la valeur livrée**, pas la valeur capturée. (Activité, pas paiement.)
2. **Représente vision et stratégie**. La metric devrait être une phrase qui résume la promesse du produit.
3. **Leading indicator of revenue**. Si ça monte, le revenue suit ; si ça descend, le revenue baisse.
4. **Actionnable**. Les équipes peuvent influencer le NSM par leurs choix.
5. **Compréhensible**. Toute personne dans la boîte peut le citer.

---

## Les 3-5 input metrics (la "constellation")

Le NSM est **composé** de 3 à 5 inputs. La règle : si tu peux additionner / multiplier / pondérer les inputs pour reconstruire le NSM, tu as la bonne décomposition.

Exemple Airbnb :
```
Nights booked = #Active travelers × Booking frequency × Average length of stay
```

Trois inputs. Chacun **actionnable indépendamment**. Chacun a un **owner** dans l'org.

Exemple campagne promo (notre projet) :
```
Conversions attribuées = Reach × CTR × Conversion rate
```
Ou pour leads B2B :
```
SQLs/month = MQLs × Qualification rate × Velocity factor
```

---

## Anti-patterns

### 1. NSM = vanity metric

> Anti-pattern : *"Notre NSM est de 1M followers Twitter d'ici fin d'année."*

Followers ne mesure pas la valeur livrée. C'est une vanity metric.

### 2. NSM = revenue déguisé

> Anti-pattern : *"Notre NSM est ARR."*

ARR est lagging. Pas de signal early. Pas de levier d'action.

### 3. Trop d'inputs

> Anti-pattern : NSM avec 12 inputs.

Si tu as 12 inputs, aucun n'est actionnable réellement. Limite stricte : 3-5.

### 4. Inputs non-additifs

> Anti-pattern : inputs qui ne reconstruisent pas le NSM.

Si NSM = X et inputs = A, B, C mais X n'est pas une fonction de A, B, C → tu as juste une liste de KPI, pas un framework.

---

## Application dans `promote-strategist`

En P3 étape `m`, le strategist :

1. Lit le goal primaire de la campagne (`STATE.yaml.goal`) : awareness / leads / sales.
2. Choisit le NSM correspondant à ce goal :
   - **awareness** → Branded search volume / Mentions tracked
   - **leads** → SQLs/month (qualifiés)
   - **sales** → Attributed conversions × ASP (avec attribution self-reported pour le B2B)
3. Décompose en 3-5 inputs actionnables.
4. Pour chaque input : nomme le **owner** (canal / channel-skill responsable) et la **fréquence de mesure**.

Output structuré :

```markdown
## North Star Metric

**NSM** : [nom + définition d'une phrase]
**Why this NSM** : [pourquoi ça capture la valeur, pas la vanity]
**Frequency of review** : [weekly | monthly]

## Input metrics (3-5)

| Input | Definition | Owner (skill/channel) | Target | Frequency |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |
```

Voir aussi `./attribution-canon.md` pour les pièges de mesure (dark social, self-reported).

---

## Citations utiles

> *"If your NSM doesn't change for 6 months, you don't have an NSM — you have a dashboard."*

> *"The point of the North Star isn't to know where you are. It's to know which way is forward."*

> *"Tracking a vanity metric long enough makes it feel real. Choose carefully."*
