#!/bin/bash
set -e

HOOKS_DIR="${HOME}/.config/git/hooks"
HOOK_PATH="${HOOKS_DIR}/prepare-commit-msg"

if [ -f "$HOOK_PATH" ]; then
    rm "$HOOK_PATH"
    echo "Removed: $HOOK_PATH"
fi

# Only unset core.hooksPath if it points to our dir
CURRENT=$(git config --global --get core.hooksPath 2>/dev/null || true)
if [ "$CURRENT" = "$HOOKS_DIR" ]; then
    git config --global --unset core.hooksPath
    echo "Unset: git config --global core.hooksPath"
fi

# Remove hooks dir if it's now empty
if [ -d "$HOOKS_DIR" ] && [ -z "$(ls -A "$HOOKS_DIR")" ]; then
    rmdir "$HOOKS_DIR"
    echo "Removed empty dir: $HOOKS_DIR"
fi

echo "Done."
