# Copy Frameworks — PAS, AIDA, et obsolescences

> **Source** : copywriting tradition (Ogilvy, Schwartz, Halbert, Sugarman, Caples). Voir aussi `promote-schwartz` (skill) pour les Stages of Awareness, et `promote-cialdini` pour les leviers psychologiques.
> **Rôle dans le projet** : grille rapide pour structurer un copy de promo (post, email, landing). À ne PAS utiliser comme **substitut** à JTBD/Dunford/Schwartz — c'est une grammaire de **forme**, pas de fond.

---

## Frameworks vivants (à utiliser)

### PAS — Problem / Agitate / Solve

Le framework copy le plus utilisé en 2026. Universel, simple, efficace.

```
PROBLEM   : Tu vis [situation X], et c'est [pain spécifique].
AGITATE   : Si ça continue, [conséquence pire]. Tu as essayé [Y, Z], aucun n'a marché parce que [reason].
SOLVE     : [Solution] — voici comment, voici la preuve, voici le CTA.
```

Exemple :
> *Tu produis du contenu mais tu n'as pas de stratégie de promotion. (P)
> Chaque post finit dans le vide, et tu commences à douter de ta voix. (A)
> Avec promote-strategist, tu reçois en 30 minutes un dossier de stratégie de niveau consultant senior. (S)*

**Quand l'utiliser** : posts X/LinkedIn, sales pages, emails de séquence.

### AIDA — Attention / Interest / Desire / Action

Le framework le plus ancien (1898, E. St. Elmo Lewis). Toujours valide pour les **landing pages longues**.

```
ATTENTION : Hook visuel + headline qui interrompt.
INTEREST  : Pourquoi ce produit a un POV unique.
DESIRE    : Le futur état du user après usage. Bénéfices concrets, social proof.
ACTION    : CTA unique, sans friction.
```

**Quand l'utiliser** : long-form sales pages, founder essays.

### BAB — Before / After / Bridge

Variante simple de PAS qui marche pour **transformation stories**.

```
BEFORE : Voici comment c'est aujourd'hui (douleur).
AFTER  : Voici comment ce serait (état désiré, concret).
BRIDGE : Voici le pont — le produit/méthode.
```

**Quand l'utiliser** : témoignages clients, case studies.

### 4U Headlines (Useful / Urgent / Unique / Ultra-specific)

Pas un framework de copy entier, mais une checklist pour **headlines**. Un bon headline coche au moins 3 des 4 :

- **Useful** : le user voit immédiatement le bénéfice.
- **Urgent** : il y a une raison d'agir maintenant (pas dans 6 mois).
- **Unique** : pas un cliché de l'industrie.
- **Ultra-specific** : un nombre, un nom, une condition concrète.

Exemple coche 4/4 : *"How a solo dev got 10K signups in 30 days using a $0 organic strategy"*.
Exemple coche 0/4 : *"Grow your business with our innovative platform"*.

---

## Frameworks à utiliser avec prudence

### FAB — Features / Advantages / Benefits

```
FEATURE   : Le produit a [tech detail].
ADVANTAGE : Ça permet de [capability].
BENEFIT   : Donc tu gagnes [outcome].
```

**Pourquoi avec prudence** : FAB part des features. C'est l'**inverse** de JTBD (qui part du job). En 2026, FAB-only produit du copy product-centric qui ne convertit pas.

**Quand acceptable** : pages techniques pour audiences déjà-acquises (docs, comparison technique).

### The 5 Cs (Clear / Concise / Compelling / Credible / Conversion-focused)

Pas un framework structurel, mais une checklist d'audit. Utile en review.

---

## Frameworks obsolètes (à ne PAS utiliser comme primaire)

### 4 Ps (Promise / Picture / Proof / Push)

Le 4Ps de marketing académique (Product / Price / Place / Promotion) est un cadre **de strat marketing**, pas de copy. Le 4Ps de copy (Promise / Picture / Proof / Push) est un dérivé d'AIDA, redondant.

> Statut : OBSOLÈTE comme framework copy. Ne l'utilise pas — utilise AIDA ou PAS.

### "Tell a story"

Trop vague. La narration est partout, mais "raconte une histoire" sans structure produit du contenu décousu. Utilise StoryBrand SB7 si tu veux du narratif templatisé (mais voir warning ci-dessous), ou Schwartz pour la profondeur.

### StoryBrand SB7

Statut **discuté** dans le plan : monomythe templatisé (héros / guide / plan / call / échec / succès). Reconnaissable au premier coup d'œil dans tous les sites qui l'ont adopté. **Évite** comme cadre central. **Utile** pour comprendre pourquoi tant de landings se ressemblent.

---

## Le pattern AI-tell #1 dans la copy générée

Voir `./skill-grammar.md` Partie 5 — Pattern #11 (Explanatory Extension). Le LLM produit naturellement de la copy qui s'auto-explique :

> Anti-pattern : *"Notre produit est rapide — ce qui veut dire que vous économisez du temps, ce qui est crucial dans un monde où le temps est précieux."*

Trois clauses pour dire "rapide". Le LLM est dressé pour ce style. La copy qui marche est **plus brutale, plus courte, moins explicative**.

> Mieux : *"Notre produit est rapide. Trois minutes pour ce qui prenait une heure."*

À noter dans tout SKILL.md qui produit du copy.

---

## Application dans `promote-strategist`

Le strategist ne produit pas de copy finale (c'est le job de `promote-executor` Partie 2). Mais il **prescrit le framework copy** dans `strategy/07-content-pillars.md` :

```markdown
## Copy framework recommendations

For each content pillar:

| Pillar | Primary copy framework | Rationale |
|---|---|---|
| Pillar 1 | PAS | Audience is solution-aware, problem-acute |
| Pillar 2 | AIDA (long-form) | Founder essays, deep dives |
| Pillar 3 | BAB | Customer stories, transformation focus |
| ... | ... | ... |

## Anti-patterns to avoid in all copy

- Pattern #11 (explanatory extension) — see ./skill-grammar.md
- FAB-only (feature-listing without job context)
- Generic headlines (failing 4U test on >2 dimensions)
- StoryBrand SB7 templating (recognizable, fatigued)
```

---

## Citations utiles

> *"The headline is 80% of the ad. If the headline doesn't get them, nothing else will."* — David Ogilvy

> *"You don't write copy. You write conversations with one specific person."* — Eugene Schwartz paraphrase

> *"The best copy is the simplest copy that survives a brutal edit."*
