# Audit d'autonomie — Phase 0.A.5

Date : 2026-04-28

Vérifie que chaque skill importé est utilisable sans aucune référence à un fichier hors de `promote/`.

## Méthode

Pour chaque skill dans `.claude/skills/promote-*/` (hors skills à créer ultérieurement) :

1. Scan des chemins absolus suspects via `grep -rn -E '(/home/|~/.claude|~/.agents|/Users/|/opt/|/etc/)'`.
2. Scan des invocations de skills par leur nom non-préfixé (ex : `alex-hormozi-perspective`, `huashu-nuwa`).
3. Scan des scripts (`*.py`, `*.sh`) pour `os.path.expanduser`, `~/`, `/home/`.
4. Vérification que les invocations textuelles d'autres skills (mentionnées dans les docstrings) sont bénignes (exemples documentaires, pas du code exécuté).

Verdict possible : `AUTONOME` / `PATCHÉ` / `BROKEN`.

## Résultats par skill

### `promote-hormozi` — AUTONOME

- 3 occurrences regex `home/...` détectées dans `references/research/06-timeline.md`.
- **Toutes des faux positifs** : ce sont des URLs publiques (`businesswire.com/news/home/...`).
- Aucun chemin absolu local. Aucune invocation de skill global.
- **Verdict : AUTONOME, aucune modification nécessaire**.

### `promote-ammar` — PATCHÉ

- 2 chemins absolus dans `references/phase4-validation.md` (entête : `File evaluated: /home/kala/.agents/skills/...`).
- **Patch appliqué** : remplacés par des références relatives au skill (`SKILL.md`, `references/research/`).
- Aucune invocation de skill global.
- Note : 4 scripts utilitaires (`srt_to_transcript.py`, `download_subtitles.sh`, `quality_check.py`, `merge_research.py`) dans `scripts/` — vestiges de l'environnement de build huashu-nuwa, non appelés au runtime du skill. Conservés (taille négligeable, pas de référence externe). Pourraient être nettoyés ultérieurement si redistribution publique.
- **Verdict : PATCHÉ, autonome**.

### `promote-paul-graham` — AUTONOME

- Aucune référence externe détectée.
- **Verdict : AUTONOME**.

### `promote-x-mastery` — AUTONOME

- Aucune référence externe détectée.
- **Verdict : AUTONOME**.

### `promote-mrbeast` — AUTONOME

- Aucune référence externe détectée.
- **Verdict : AUTONOME**.

### `promote-steve-jobs` — AUTONOME

- Aucune référence externe détectée.
- **Verdict : AUTONOME**.

### `promote-huashu-nuwa` — AUTONOME

- Une seule occurrence du nom `huashu-nuwa` : le frontmatter `name:` lui-même (déjà renommé en `promote-huashu-nuwa`, donc plus présent comme `huashu-nuwa` brut).
- 4 scripts utilitaires de build (idem `promote-ammar`). Ces scripts sont la raison d'être du skill (Phase 1/2 va les utiliser pour générer les operator/framework skills via `promote-huashu-nuwa`).
- Les docstrings des scripts contiennent des exemples (`python3 quality_check.py .claude/skills/elon-musk-perspective/SKILL.md`) qui mentionnent un autre skill local. **Bénin** : c'est de la documentation, pas du code exécuté ; l'utilisateur du script substituera son propre chemin de skill cible.
- Images de cover/assets/examples omises lors de l'import (taille réduite de 25MB à 88K). Aucun fichier dans `SKILL.md`/`references/`/`scripts/` ne référence ces images, donc l'omission est sûre.
- **Verdict : AUTONOME**.

## Synthèse

| Skill | Verdict | Action |
|---|---|---|
| `promote-hormozi` | AUTONOME | Aucune |
| `promote-ammar` | PATCHÉ | `references/phase4-validation.md` corrigé |
| `promote-paul-graham` | AUTONOME | Aucune |
| `promote-x-mastery` | AUTONOME | Aucune |
| `promote-mrbeast` | AUTONOME | Aucune |
| `promote-steve-jobs` | AUTONOME | Aucune |
| `promote-huashu-nuwa` | AUTONOME | Aucune (build utilitaires conservés volontairement) |

**Tous les skills importés sont autonomes**. Le système est prêt pour Phase 0.B (audit publics) et au-delà.

## Vestiges à considérer pour la distribution publique

Lors de la préparation d'une release publique, envisager :

1. Supprimer `scripts/` de `promote-ammar` (vestiges de build inutiles au runtime du skill).
2. Remplacer dans les docstrings `quality_check.py` et `merge_research.py` l'exemple `elon-musk-perspective` par un placeholder `<your-skill-name>`.
3. Vérifier les licences des skills locaux (probablement créés par François via huashu-nuwa, donc ses droits) et les afficher dans `docs/attributions.md`.

Ces actions sont cosmétiques et n'affectent pas l'autonomie technique du système.
