#!/usr/bin/env bash
set -euo pipefail

# Run MLST over a chunk of the manifest.
# Designed for LSF array jobs to avoid oversized job arrays.
#
# Usage (LSF):
#   CHUNK_SIZE=100
#   bsub -J "mlst[1-<N>]" ... scripts/03_mlst_chunk.sh <chunk_size>
#
# Output: out/mlst/<sample>.mlst.tsv

source scripts/00_vars.sh
activate_env

CHUNK_SIZE="${1:-100}"
MANIFEST="$MANIFEST_DIR/genomes.tsv"

[[ -s "$MANIFEST" ]] || die "Missing manifest: $MANIFEST"

IDX="${LSB_JOBINDEX:-1}"

START=$(( (IDX - 1) * CHUNK_SIZE + 2 ))  # skip header (line 1)
END=$(( START + CHUNK_SIZE - 1 ))

echo "[INFO] MLST chunk index=$IDX  lines=$START..$END  chunk_size=$CHUNK_SIZE"

# Pull the lines for this chunk and process
sed -n "${START},${END}p" "$MANIFEST" | while IFS=$'\t' read -r SPECIES SAMPLE FASTA; do
  [[ -n "${SAMPLE:-}" ]] || continue
  OUT="$OUT_MLST/${SAMPLE}.mlst.tsv"
  if [[ -s "$OUT" ]]; then
    echo "[INFO] $SAMPLE: MLST already exists (skip)"
    continue
  fi
  if [[ ! -s "$FASTA" ]]; then
    echo "[WARN] $SAMPLE: missing FASTA ($FASTA) (skip)"
    continue
  fi
  echo "[INFO] MLST: $SAMPLE ($SPECIES)"
  # mlst writes one line per genome; we keep raw output
  mlst "$FASTA" > "$OUT" 2> "$OUT_MLST/${SAMPLE}.mlst.err" || {
    echo "[WARN] MLST failed for $SAMPLE (see $OUT_MLST/${SAMPLE}.mlst.err)"
    rm -f "$OUT"
  }
done

echo "[INFO] MLST chunk complete."
