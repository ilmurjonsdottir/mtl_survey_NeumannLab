#!/usr/bin/env bash
set -euo pipefail

# Downsample non-fragmented list to MAX genomes per species (keeps first MAX per species).
# Output: out/filtered/genomes_mlst_nonfragmented_downsampled.tsv

source scripts/00_vars.sh

IN="$OUT_FILTER/genomes_mlst_nonfragmented.tsv"
OUT="$OUT_FILTER/genomes_mlst_nonfragmented_downsampled.tsv"
MAX_PER_SPECIES="${1:-500}"

[[ -s "$IN" ]] || die "Missing input: $IN"

head -n1 "$IN" > "$OUT"
tail -n +2 "$IN" | awk -v max="$MAX_PER_SPECIES" '
{
  sp=$1
  if (count[sp] < max) { count[sp]++; print $0 }
}
' >> "$OUT"

echo "[INFO] Wrote: $OUT"
echo "[INFO] Counts:"
cut -f1 "$OUT" | tail -n +2 | sort | uniq -c | sort -k2,2
