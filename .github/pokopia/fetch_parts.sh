#!/bin/bash
# fetch_parts.sh <repo> <tag> <manifest asset> <out file>: download the parts a manifest lists (idx name size sha256), verify each, concatenate into <out file>.
# Parts are deleted as soon as they are appended, so the peak disk use is the output plus one part.
set -euo pipefail
REPO=$1; TAG=$2; MAN=$3; OUT=$4; TMP=$(mktemp -d)
gh release download "$TAG" --repo "$REPO" -p "$MAN" -D "$TMP" --clobber
: > "$OUT"
while IFS=$'\t' read -r idx name size sha; do
  [ -n "${idx:-}" ] || continue
  case "$idx" in \#*) continue;; esac
  echo "  part $name ($size bytes)"
  ok=0
  for i in 1 2 3; do
    gh release download "$TAG" --repo "$REPO" -p "$name" -D "$TMP" --clobber || { sleep 15; continue; }
    got=$(stat -f %z "$TMP/$name"); got_sha=$(shasum -a 256 "$TMP/$name" | cut -d' ' -f1)
    if [ "$got" = "$size" ] && [ "$got_sha" = "$sha" ]; then ok=1; break; fi
    echo "  bad part $name size=$got/$size sha=$got_sha/$sha (try $i)"; sleep 15
  done
  [ "$ok" = 1 ] || { echo "::error::part $name of $TAG failed verification"; exit 1; }
  cat "$TMP/$name" >> "$OUT"; rm -f "$TMP/$name"
done < "$TMP/$MAN"
rm -rf "$TMP"
