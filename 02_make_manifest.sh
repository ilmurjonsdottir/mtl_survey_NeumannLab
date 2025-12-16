#!/usr/bin/env bash
set -euo pipefail

# Build manifest from genomes/<species>/*.fna
# Output: manifest/genomes.tsv (species, sample, fasta)

source scripts/00_vars.sh

OUT="$MANIFEST_DIR/genomes.tsv"

echo "[INFO] Writing manifest to $OUT"
echo -e "species	sample	fasta" > "$OUT"

for DIR in "$GENOMES_DIR"/*; do
  [[ -d "$DIR" ]] || continue
  SPECIES=$(basename "$DIR")
  for F in "$DIR"/*.fna; do
    [[ -f "$F" ]] || continue
    SAMPLE=$(basename "$F" .fna)
    printf "%s	%s	%s
" "$SPECIES" "$SAMPLE" "$F" >> "$OUT"
  done
done

echo "[INFO] Done. Preview:"
head "$OUT"
