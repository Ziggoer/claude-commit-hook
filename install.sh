#!/bin/bash
set -e

REPO_RAW="https://raw.githubusercontent.com/Ziggoer/claude-commit-hook/main"
HOOK_NAME="prepare-commit-msg"
HOOKS_DIR="${HOME}/.config/git/hooks"
HOOK_PATH="${HOOKS_DIR}/${HOOK_NAME}"

# 1. Check claude CLI
if ! command -v claude >/dev/null 2>&1; then
    echo "Error: 'claude' CLI not found."
    echo "Install Claude Code first: https://docs.claude.com/en/docs/claude-code/overview"
    exit 1
fi

# 2. Check existing core.hooksPath
EXISTING=$(git config --global --get core.hooksPath 2>/dev/null || true)
if [ -n "$EXISTING" ] && [ "$EXISTING" != "$HOOKS_DIR" ]; then
    echo "Warning: global core.hooksPath is already set to:"
    echo "  $EXISTING"
    echo "Installing will override it. Existing hooks there will NOT be copied."
    printf "Continue? [y/N] "
    read -r answer
    case "$answer" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Aborted."; exit 1 ;;
    esac
fi

# 3. Install hook
mkdir -p "$HOOKS_DIR"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/${HOOK_NAME}" ]; then
    cp "${SCRIPT_DIR}/${HOOK_NAME}" "$HOOK_PATH"
else
    curl -fsSL "${REPO_RAW}/${HOOK_NAME}" -o "$HOOK_PATH"
fi
chmod +x "$HOOK_PATH"

# 4. Configure git
git config --global core.hooksPath "$HOOKS_DIR"

echo ""
echo "Installed: ${HOOK_PATH}"
echo "Configured: git config --global core.hooksPath = ${HOOKS_DIR}"
echo ""
echo "Try it: in any repo, stage changes and run 'git commit' (without -m)."
