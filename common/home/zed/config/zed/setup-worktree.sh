#!/usr/bin/env bash
# ===============================================
# Set up of dependencies on Zed worktree trigger
#      Compatible with macOS and Linux
# ===============================================
set -euo pipefail

install_bun_dependencies() {
  echo "→ Bun project"
  bun install --frozen-lockfile
}

install_pnpm_dependencies() {
  echo "→ pnpm project"
  pnpm install --frozen-lockfile
}

install_yarn_dependencies() {
  echo "→ Yarn project"
  yarn install --frozen-lockfile
}

install_npm_dependencies() {
  if [[ -f package-lock.json ]]; then
    echo "→ npm project"
    npm ci
  else
    echo "→ Node project (no lockfile)"
    npm install
  fi
}

install_javascript_dependencies() {
  if [[ -f bun.lockb || -f bun.lock ]]; then
    install_bun_dependencies
  elif [[ -f pnpm-lock.yaml ]]; then
    install_pnpm_dependencies
  elif [[ -f yarn.lock ]]; then
    install_yarn_dependencies
  else
    install_npm_dependencies
  fi
}

resolve_mill_dependencies() {
  echo "→ Mill project"
  mill resolve _
}

bootstrap_worktree_dependencies() {
  local worktree_root
  worktree_root="$(git rev-parse --show-toplevel)"
  cd "$worktree_root"

  echo "Setting up dependencies for: $worktree_root"

  if [[ -f package.json ]]; then
    install_javascript_dependencies
  fi

  if [[ -f build.sc ]]; then
    resolve_mill_dependencies
  fi

  echo "Done."
}

bootstrap_worktree_dependencies "$@"
