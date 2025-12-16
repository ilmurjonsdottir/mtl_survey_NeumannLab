#!/usr/bin/env bash
set -euo pipefail

# Download genomes for each species using NCBI Datasets CLI, then collect .fna files.
# Produces: genomes/<Species>/*.fna
#
# This script is resumable:
# - If the species directory already contains .fna files, it will skip download/collect.
#
# Requirements: datasets, unzip

source scripts/00_vars.sh
activate_env

echo "[INFO] Starting genome download on $(hostname)"

for SPECIES in "${SPECIES_LIST[@]}"; do
  OUT_SPECIES_DIR="$GENOMES_DIR/$SPECIES"
  mkdir -p "$OUT_SPECIES_DIR"

  # If we already have genomes collected, skip.
  if ls "$OUT_SPECIES_DIR"/*.fna >/dev/null 2>&1; then
    echo "[INFO] $SPECIES: genomes already present in $OUT_SPECIES_DIR (skipping)"
    continue
  fi

  TAX="${TAXID[$SPECIES]}"
  [[ -n "${TAX:-}" ]] || die "Missing taxid for $SPECIES in scripts/00_vars.sh"

  ZIP="$OUT_SPECIES_DIR/${SPECIES}.zip"
  WORK="$OUT_SPECIES_DIR/_datasets_tmp"

  rm -rf "$WORK"
  mkdir -p "$WORK"

  echo "[INFO] Downloading $SPECIES (taxid=$TAX)"
  # Keep this command minimal (flags change between datasets versions).
  # This form worked reliably: download all assemblies under the taxon.
  datasets download genome taxon "$TAX" --filename "$ZIP"     > "$LOGS_DIR/datasets_${SPECIES}.log" 2>&1 || {
      echo "[ERROR] datasets failed for $SPECIES. See $LOGS_DIR/datasets_${SPECIES}.log"
      rm -rf "$WORK"
      continue
    }

  echo "[INFO] Unzipping package for $SPECIES"
  unzip -q -o "$ZIP" -d "$WORK"

  echo "[INFO] Collecting genomic FASTA for $SPECIES"
  # NCBI Datasets layout typically: ncbi_dataset/data/<assembly_accession>/*.fna
  find "$WORK" -type f \( -name "*_genomic.fna" -o -name "*genomic.fna" -o -name "*.fna" \)     | grep -E "ncbi_dataset/data"     | while read -r F; do
        BN="$(basename "$F")"
        # copy as-is into genomes/<species>/
        cp -f "$F" "$OUT_SPECIES_DIR/$BN"
      done

  COUNT=$(ls "$OUT_SPECIES_DIR"/*.fna 2>/dev/null | wc -l | tr -d ' ')
  echo "[INFO] Done with $SPECIES, collected $COUNT genomes."

  rm -rf "$WORK"
done

echo "[INFO] Download step complete."
