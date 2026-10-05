#!/usr/bin/env bash

# Usage: run-or-compile.sh <script.scala> [args...]
# Runs the cached native binary from <script-dir>/compiled/<name>,
# rebuilding it with scala-cli when missing or older than the source.
# macOS + Linux.
set -euo pipefail

src="$1"
shift
dir="$(cd "$(dirname "$src")" && pwd)"
name="$(basename "$src" .scala)"
bin="$dir/compiled/$name"

mkdir -p "$dir/compiled"

if [[ -x "$bin" && "$bin" -nt "$src" ]]; then
  exec "$bin" "$@"
fi

if scala-cli --power package --native "$src" -o "$bin.tmp"; then
  chmod +x "$bin.tmp"
  mv -f "$bin.tmp" "$bin"
  exec "$bin" "$@"
fi

exec scala-cli run "$src" -- "$@"
