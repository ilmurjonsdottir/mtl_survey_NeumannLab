#!/usr/bin/env bash
set -euo pipefail

# Helper to submit MLST array with safe array size.
# It computes number of manifest lines and submits an array where each task processes CHUNK_SIZE genomes.

source scripts/00_vars.sh
activate_env

CHUNK_SIZE="${1:-100}"
MANIFEST="$MANIFEST_DIR/genomes.tsv"
[[ -s "$MANIFEST" ]] || die "Missing manifest: $MANIFEST"

N_TOTAL=$(( $(wc -l < "$MANIFEST") - 1 ))
N_TASKS=$(( (N_TOTAL + CHUNK_SIZE - 1) / CHUNK_SIZE ))

echo "[INFO] Manifest genomes: $N_TOTAL"
echo "[INFO] Chunk size: $CHUNK_SIZE"
echo "[INFO] Submitting array: 1-$N_TASKS"

# Submit inline to avoid editing the .lsf each time
bsub -J "mlst_chunk[1-${N_TASKS}]" -q standard -n 1 -M 4000 -W 12:00   -R "span[hosts=1] rusage[mem=4000]"   -o "logs/03_mlst.%J.%I.out" -e "logs/03_mlst.%J.%I.err"   bash scripts/03_mlst_chunk.sh "$CHUNK_SIZE"
