# Category Design — Play Bigger

> **Source canonique** : Lochhead, Ramadan, Peterson, Maney, *Play Bigger* (HarperBusiness, 2016). Travaux ultérieurs de Christopher Lochhead (Category Pirates substack, podcast *Lochhead on Marketing*).
> **Rôle dans le projet** : Étape **AMONT** de `promote-dunford-positioning`. On ne se positionne pas dans une catégorie tant qu'on n'a pas décidé **quelle catégorie**. Particulièrement critique en 2026 où l'AI a explosé les catégories existantes.

---

## Idée centrale

> *"Companies that create a new category capture 76% of the market value in that category."* — Play Bigger

On ne vend pas un produit. On **conditionne une catégorie**. Le category king (le créateur/leader d'une nouvelle catégorie) capture la majorité de la valeur économique.

**Implication** : la stratégie de promotion d'un produit qui *concourt dans une catégorie existante* est radicalement différente de celle d'un produit qui *crée une nouvelle catégorie*.

---

## Les 3 modes de positionnement-marché

| Mode | Ce qu'on fait | Quand l'adopter |
|---|---|---|
| **Better** | "Nous sommes meilleurs que [concurrent X]" | Catégorie mature, on est late entrant et on doit gagner par exécution. Difficile, marges écrasées. |
| **Different** | "Nous sommes différents de [concurrent X]" | Catégorie existante mais on a une asymétrie. Mode Dunford classique. |
| **Different & Better via category creation** | "Nous créons une nouvelle catégorie : [nom]. Le vieux monde était [X], le nouveau monde est [Y]." | Quand on a un POV (Point of View) légitime sur un problème **non-encore-nommé**. Mode Play Bigger. |

---

## Le POV (Point of View) — l'arme du category designer

> *"The POV is the answer to: What is the problem in the world that we see and solve in a unique way?"*

Un POV se compose de :

1. **Naming the problem** : nommer un problème que personne n'a encore nommé clairement. Donner du langage à une douleur diffuse.
2. **Naming the world that should exist** : décrire le futur où ce problème est résolu.
3. **Naming the category** : donner un nom à la solution-classe qu'on incarne.

Test du POV : si tu peux le résumer en *"Nous croyons que [observation contre-intuitive sur le problème]. Nous appelons [nom du problème] le défi central de [domaine]. La solution est [nom de la nouvelle catégorie]."*, tu as un POV.

Sans POV, "category creation" = greenwashing marketing.

---

## Les 5 stades d'une catégorie

| Stade | Description | Implications promo |
|---|---|---|
| **Cold start** | La catégorie n'existe pas. Personne n'a le langage. | Phase d'éducation, contenu missionnaire, peu de captation. |
| **Tipping point** | Quelques early adopters comprennent. Les analystes commencent à utiliser le langage de la catégorie. | Pousser le langage agressivement, capter les early followers. |
| **Escape velocity** | La catégorie est reconnue. La presse en parle. Les concurrents apparaissent. | Cementer la position de leader/king. |
| **Maturity** | La catégorie est saturée. | Defense + expansion vers catégories adjacentes. |
| **Decline** | La catégorie est obsolète ou consolidée. | Sortir, pivoter, ou créer une nouvelle catégorie. |

Un produit en **cold start** a une stratégie de promotion radicalement différente d'un produit en **escape velocity**. Identifier le stade est non-optionnel.

---

## "Lightning Strike" — le moment de la catégorie king

> *"You don't get to be a category king by playing nice over many quarters. You get there by orchestrating a Lightning Strike — a coordinated, audacious, emotionally arresting moment when the world realizes the new category exists."*

Un lightning strike combine :
- Un **moment d'attention** (lancement, événement, étude majeure, prise de position publique).
- Une **avalanche de preuves** (clients, données, témoignages, presse).
- Un **flag planté** dans le langage (le nom de la catégorie martelé).

Anti-pattern : tenter d'amener une nouvelle catégorie avec du contenu de fond régulier sans moment de bascule.

---

## Application dans le pipeline (AMONT de Dunford)

À utiliser dans P3 du `promote-strategist`, AVANT d'invoquer `promote-dunford-positioning`. Le strategist se pose 3 questions :

1. **Mode-marché** : ce produit est en mode Better, Different, ou Different+Category Creation ? (Si Better : skip Play Bigger, on fait juste Dunford classique.)
2. **POV** : si Different+Category Creation, le POV est-il articulé en 3 lignes ? Si non, le marquer comme `hypothesis_to_validate` plutôt que de fabriquer un POV creux.
3. **Stade** : quel stade actuel de la catégorie ? Cold start / tipping / escape / mature / decline ? Le plan promo en dépend.

L'output de cette étape (`strategy/03-positioning.md` section 1) :

```markdown
## Category-market mode

- **Mode** : [Better | Different | Different & category creation]
- **Si category creation : POV**
  - Problem we name : [...]
  - World that should exist : [...]
  - Category name : [...]
- **Stade actuel de la catégorie** : [cold-start | tipping | escape | mature | decline]
- **Implications promo** : [découle du stade — éducation vs amplification vs defense]
```

---

## Tensions à gérer

- **Category Design vs Dunford Positioning** : ne PAS faire les deux à plat. Category Design DÉCIDE la catégorie. Dunford POSITIONNE dedans.
- **Risque "AI agent for X"** : en 2026, claim une nouvelle catégorie *"AI agent for X"* est devenu cliché. La category design est plus dure et plus précieuse. Si le POV n'est qu'un repackaging "AI + catégorie existante", marquer `weak_pov, defaulting_to_different_mode`.

---

## Citations utiles

> *"The market doesn't choose the category leader. The category leader chooses the market."*

> *"Designing a category and the company that wins that category are two sides of the same coin."*

> *"Most companies focus on competing for the category. Category kings focus on creating it."*
