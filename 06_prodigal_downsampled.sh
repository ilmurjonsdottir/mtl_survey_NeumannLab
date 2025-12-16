#!/usr/bin/env bash
set -euo pipefail

# Predict proteomes for the downsampled, MLST-complete set.
# Output per genome: out/proteomes/<sample>/<sample>.faa

source scripts/00_vars.sh
activate_env

LIST="$OUT_FILTER/genomes_mlst_nonfragmented_downsampled.tsv"
[[ -s "$LIST" ]] || die "Missing list: $LIST"

echo "[INFO] Running Prodigal for downsampled set: $LIST"

tail -n +2 "$LIST" | while IFS=$'\t' read -r SPECIES SAMPLE FASTA ST; do
  OUTDIR="$OUT_PROT/$SAMPLE"
  FAA="$OUTDIR/${SAMPLE}.faa"
  mkdir -p "$OUTDIR"

  if [[ -s "$FAA" ]]; then
    continue
  fi

  if [[ ! -s "$FASTA" ]]; then
    echo "[WARN] Missing FASTA: $FASTA"
    continue
  fi

  echo "[INFO] Prodigal: $SAMPLE ($SPECIES)"
  prodigal -i "$FASTA" -a "$FAA" -p single >/dev/null 2>&1 || {
    echo "[WARN] Prodigal failed: $SAMPLE"
    rm -f "$FAA"
  }
done

echo "[INFO] Prodigal complete."
