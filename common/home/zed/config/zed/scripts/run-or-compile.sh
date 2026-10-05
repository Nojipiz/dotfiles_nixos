#!/usr/bin/env bash
#
# Usage: run-or-compile.sh <script.scala> [args...]
#
# Run a script through its cached binary when the binary is newer than the
# source, rebuilding it otherwise.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: run-or-compile.sh <script.scala> [args...]" >&2
  exit 2
fi

src="$1"
shift
name="$(basename "$src" .scala)"
# The script itself may sit on a read-only mount (nix store), and the
# current directory belongs to the caller, so nothing writable goes
# next to the script or into the cwd.
cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}/zed/scripts/compiled"
bin="$cacheDir/$name"

mkdir -p "$cacheDir"

if [[ -x "$bin" && "$bin" -nt "$src" ]]; then
  exec "$bin" "$@"
fi

# Only the packaging step runs in the cache dir, so build scratch never
# touches the read-only script dir or the caller's directory. The binary
# and the fallback below run in the caller's directory.
if ( cd "$cacheDir" && scala-cli --power package --native "$src" -o "$bin.tmp" ); then
  # Via a temp file so an interrupted build never leaves a half-written
  # binary behind for the freshness check above to mistake as current.
  chmod +x "$bin.tmp"
  mv -f "$bin.tmp" "$bin"
  exec "$bin" "$@"
fi

exec scala-cli run "$src" -- "$@"
