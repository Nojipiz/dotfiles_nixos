#!/usr/bin/env bash
# ====== Set up of dependencies on Zed worktree trigger ======
# Compatible with macOS and Linux.
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

find_sibling_worktree_holding_env_files() {
  local worktree_root="$1"
  local worktree_entry
  local candidate_worktree
  while IFS= read -r worktree_entry; do
    candidate_worktree="${worktree_entry#worktree }"
    if [[ "$candidate_worktree" == "$worktree_root" ]]; then
      continue
    fi
    if git -C "$candidate_worktree" ls-files --others --ignored --exclude-standard 2>/dev/null | grep -qE '(^|/)\.env([^/]*)$'; then
      echo "$candidate_worktree"
      return 0
    fi
  done < <(git worktree list --porcelain | grep '^worktree ')
  echo ""
  return 0
}

copy_env_files_from_sibling_worktree() {
  local worktree_root="$1"
  local sibling_worktree
  sibling_worktree="$(find_sibling_worktree_holding_env_files "$worktree_root")"
  if [[ -z "$sibling_worktree" ]]; then
    echo "→ No .env files found in sibling worktrees, skipping"
    return 0
  fi

  echo "→ Copying .env files from $sibling_worktree"
  local ignored_files
  ignored_files="$(git -C "$sibling_worktree" ls-files --others --ignored --exclude-standard)"
  local env_file
  while IFS= read -r env_file; do
    case "$env_file" in
      *.example | *.sample | *.template | *.dist) continue ;;
    esac
    case "$env_file" in
      .env | */.env | .env.* | */.env.*) ;;
      *) continue ;;
    esac
    if [[ -e "$worktree_root/$env_file" ]]; then
      continue
    fi
    mkdir -p "$worktree_root/$(dirname "$env_file")"
    cp -p "$sibling_worktree/$env_file" "$worktree_root/$env_file"
    echo "  + $env_file"
  done <<< "$ignored_files"
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

  copy_env_files_from_sibling_worktree "$worktree_root"

  echo "Done."
}

bootstrap_worktree_dependencies
