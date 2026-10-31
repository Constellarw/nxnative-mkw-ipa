#!/bin/bash
# upload_parts.sh <repo> <tag> <prefix> <file>: split <file> into 1900 MB parts named <prefix>.partNN, write <prefix>.manifest.tsv, upload parts then the manifest
# (the manifest last, so a half-uploaded chunk is never picked up by the next run).
set -euo pipefail
REPO=$1; TAG=$2; PFX=$3; F=$4; D=$(dirname "$F")
(cd "$D" && split -b 1900m -a 2 "$(basename "$F")" "$PFX.part")   # macOS split: alphabetic suffixes
rm -f "$F"
: > "$D/$PFX.manifest.tsv"; i=0
for p in "$D/$PFX".part*; do
  printf '%s\t%s\t%s\t%s\n' $i "$(basename "$p")" "$(stat -f %z "$p")" "$(shasum -a 256 "$p" | cut -d' ' -f1)" >> "$D/$PFX.manifest.tsv"; i=$((i+1))
done
for p in "$D/$PFX".part*; do
  ok=0; for t in 1 2 3; do gh release upload "$TAG" --repo "$REPO" "$p" --clobber && { ok=1; break; }; sleep 20; done
  [ "$ok" = 1 ] || { echo "::error::upload of $(basename "$p") failed"; exit 1; }
  rm -f "$p"
done
gh release upload "$TAG" --repo "$REPO" "$D/$PFX.manifest.tsv" --clobber
cat "$D/$PFX.manifest.tsv"
