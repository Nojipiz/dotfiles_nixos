#!/usr/bin/env bash

# Usage: run-or-compile.sh <script.scala> [args...]
# Runs the cached native binary from ${XDG_CACHE_HOME:-$HOME/.cache}/zed/scripts/compiled/<name>,
# rebuilding it with scala-cli when missing or older than the source.
# All writes go to the cache dir: the script dir may be read-only (nix store).
# macOS + Linux.
set -euo pipefail

src="$1"
shift
name="$(basename "$src" .scala)"
cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}/zed/scripts/compiled"

mkdir -p "$cacheDir"
bin="$cacheDir/$name"

if [[ -x "$bin" && "$bin" -nt "$src" ]]; then
  exec "$bin" "$@"
fi

# Build from the cache dir so scala-cli's working files (.scala-build)
# stay out of both the (possibly read-only) script dir and the worktree.
if ( cd "$cacheDir" && scala-cli --power package --native "$src" -o "$bin.tmp" ); then
  chmod +x "$bin.tmp"
  mv -f "$bin.tmp" "$bin"
  exec "$bin" "$@"
fi

( cd "$cacheDir" && exec scala-cli run "$src" -- "$@" )
