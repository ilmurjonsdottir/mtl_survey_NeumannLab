#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Project configuration
# ------------------------------------------------------------------
BASE="/home/ijonsdot/ilmur/mtlA_survey/New_test"
cd "$BASE"

# Conda env with: datasets, unzip, mlst, prodigal, blastp/makeblastdb, python
ENV_NAME="software-bundle"

# Species list (directory names)
SPECIES_LIST=(
  "Acinetobacter_baumannii"
  "Enterococcus_faecium"
  "Escherichia_coli"
  "Staphylococcus_aureus"
  "Streptococcus_pneumoniae"
)

# NCBI Taxonomy IDs (used by NCBI Datasets)
# NOTE: Pneumococcus is 1313. Others are common NCBI IDs.
declare -A TAXID=(
  ["Acinetobacter_baumannii"]=470
  ["Enterococcus_faecium"]=1352
  ["Escherichia_coli"]=562
  ["Staphylococcus_aureus"]=1280
  ["Streptococcus_pneumoniae"]=1313
)

# ------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------
GENOMES_DIR="$BASE/genomes"
MANIFEST_DIR="$BASE/manifest"
LOGS_DIR="$BASE/logs"
OUT_DIR="$BASE/out"

OUT_MLST="$OUT_DIR/mlst"
OUT_FILTER="$OUT_DIR/filtered"
OUT_PROT="$OUT_DIR/proteomes"
OUT_HITS="$OUT_DIR/mtl_hits"
OUT_SUMMARY="$OUT_DIR/summary"

mkdir -p "$GENOMES_DIR" "$MANIFEST_DIR" "$LOGS_DIR" "$OUT_DIR"          "$OUT_MLST" "$OUT_FILTER" "$OUT_PROT" "$OUT_HITS" "$OUT_SUMMARY"

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------
activate_env() {
  # Works for conda "source activate" style envs
  source activate "$ENV_NAME"
}

die() {
  echo "[ERROR] $*" >&2
  exit 1
}
