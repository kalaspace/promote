# Attribution — promote-jtbd-switch

**Nom d'origine** : `jobs-to-be-done`
**Source publique** : wondelai/skills (JTBD framework, Christensen + Moesta)
**Date d'import** : 2026-04-28
**Renommé en** : `promote-jtbd-switch` (préfixe `promote-` pour éviter les collisions de namespace)
**Frontmatter `name:` modifié** : oui (de `jobs-to-be-done` à `promote-jtbd-switch`)

## Licence

Voir le fichier LICENSE dans le repo source. wondelai/skills et coreyhaines31/marketingskills sont publiés sous licence MIT au moment de cet import. Les références bibliographiques internes (livres, auteurs cités) restent la propriété de leurs auteurs respectifs ; ce skill est une **synthèse opérationnelle** réutilisable selon les termes MIT.

## Modifications

- Champ `name:` du frontmatter renommé.
- Audit d'autonomie (Phase 0.B) effectué : tout chemin absolu, référence externe ou invocation de skill global est patché in-place pour rendre le skill auto-suffisant dans `promote/`.
