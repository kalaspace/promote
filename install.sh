#!/usr/bin/env bash
# install.sh — Dev mode setup for promote
#
# Creates symlinks .claude/skills/promote-* → ../../skills/promote-*
# so that the project-scoped skills work locally without `/plugin install`.
#
# Use this when you've cloned the repo to contribute or fork.
# For end-user install, use `/plugin marketplace add` + `/plugin install` instead.

set -e

# Verify we're in the promote repo
if [ ! -f ".claude-plugin/plugin.json" ]; then
  echo "ERROR: .claude-plugin/plugin.json not found."
  echo "       Run this script from the root of the promote repo."
  exit 1
fi

if [ ! -d "skills" ]; then
  echo "ERROR: skills/ directory not found."
  echo "       The repo seems incomplete or you're not in the right place."
  exit 1
fi

# Create .claude/skills/ if absent
mkdir -p .claude/skills

# Count skills to link
total=$(ls -1 skills/ | wc -l)
echo "Setting up dev mode: ${total} skill symlinks"
echo ""

linked=0
skipped=0
errored=0

for skill_dir in skills/*/; do
  skill=$(basename "$skill_dir")
  target=".claude/skills/${skill}"
  source_relative="../../skills/${skill}"
  source_absolute="$(pwd)/skills/${skill}"

  # Verify source exists
  if [ ! -d "$source_absolute" ]; then
    echo "  ERROR: source missing for ${skill}: ${source_absolute}"
    errored=$((errored + 1))
    continue
  fi

  # If link/dir exists, skip
  if [ -L "$target" ]; then
    # Already a symlink — verify it points correctly
    current=$(readlink "$target")
    if [ "$current" = "$source_relative" ]; then
      skipped=$((skipped + 1))
      continue
    else
      # Wrong target, remove and recreate
      rm "$target"
    fi
  elif [ -e "$target" ]; then
    echo "  WARN: ${target} exists and is NOT a symlink. Skipping. Remove it manually if you want to re-link."
    skipped=$((skipped + 1))
    continue
  fi

  # Create the symlink (relative)
  ln -s "$source_relative" "$target"
  linked=$((linked + 1))
done

echo ""
echo "Done."
echo "  Linked  : ${linked}"
echo "  Skipped : ${skipped}"
echo "  Errored : ${errored}"
echo ""

if [ "$errored" -gt 0 ]; then
  echo "Some skills could not be linked. Check the errors above."
  exit 1
fi

echo "Dev mode active. The skills are now available at the project scope."
echo "Invoke them via /promote-strategist <url> from this repo."
echo ""
echo "To uninstall the dev symlinks: rm .claude/skills/promote-*"
