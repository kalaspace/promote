# Installation

Trois modes d'install selon ton usage. Choisis-en un.

## Mode 1 — Plugin Claude Code (production, recommandé)

Tu es un utilisateur final qui veut juste utiliser le système.

```bash
# Dans Claude Code :
/plugin marketplace add kalaspace/promote
/plugin install promote@promote-marketplace
/reload-plugins
```

Les 20 skills `promote-*` sont alors accessibles via le namespace plugin :

```
/promote:promote-strategist <url>
```

Les artefacts (campagnes) sont écrits selon la hiérarchie :

1. `$PROMOTE_HOME` si défini
2. `./campaigns/` relatif au cwd (défaut)
3. `${CLAUDE_PLUGIN_DATA}/campaigns/` fallback

## Mode 2 — Multi-agent (Cursor / Codex / Gemini en plus)

Tu utilises plusieurs agents IA et veux les skills disponibles partout.

```bash
npx skills add kalaspace/promote -g
```

Le CLI `vercel-labs/skills` détecte le dossier `skills/` à la racine et copie chaque skill vers les emplacements globaux des agents installés (`~/.claude/skills/`, `~/.cursor/`, `~/.codex/`, `~/.gemini/`).

## Mode 3 — Dev local (contribute / fork)

Tu veux modifier les skills ou contribuer.

```bash
git clone kalaspace/promote
cd promote
./install.sh
```

`install.sh` crée des symlinks `.claude/skills/promote-* → ../../skills/promote-*`. Les skills sont alors auto-scopés au projet par Claude Code, et tu peux les invoquer directement :

```
/promote-strategist <url>
```

Pour désinstaller le mode dev : `rm .claude/skills/promote-*`.

## Configuration

### Variable d'environnement

```bash
export PROMOTE_HOME=/path/to/your/campaigns
```

Override le chemin où les campagnes sont écrites. Sans cette variable, le système écrit en `./campaigns/` relatif au cwd.

### Vérification

Une fois installé, vérifier que les 20 skills sont disponibles :

```bash
# Mode 1 (plugin) :
ls ~/.claude/plugins/cache/promote/<version>/skills/

# Mode 2 (multi-agent) :
ls ~/.claude/skills/ | grep promote-

# Mode 3 (dev) :
ls -la .claude/skills/  # doivent être des symlinks
```

## Désinstallation

### Mode 1
```
/plugin uninstall promote@promote-marketplace
/plugin marketplace remove promote-marketplace
```

### Mode 2
```bash
rm -rf ~/.claude/skills/promote-*
# idem pour ~/.cursor/, ~/.codex/, ~/.gemini/
```

### Mode 3
```bash
rm .claude/skills/promote-*
```

## Pré-requis

- **Claude Code CLI** installé (≥ version qui supporte `/plugin marketplace`).
- **bash, grep, sed, ln** (standard) pour `install.sh`.
- **Python 3** pour validation JSON des manifests (optionnel).
- **Internet** pour le crawl URL et le WebSearch en P0/P2.

Pas de dépendances Node/Python obligatoires côté runtime.
