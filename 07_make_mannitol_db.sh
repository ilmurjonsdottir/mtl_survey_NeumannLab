#!/usr/bin/env bash
set -euo pipefail

# Build BLAST protein DB from ref/mannitol_refs.faa

source scripts/00_vars.sh
activate_env

REF="$BASE/ref/mannitol_refs.faa"
DB="$BASE/ref/mannitol_db"

[[ -s "$REF" ]] || die "Missing or empty reference FASTA: $REF"

echo "[INFO] Building BLAST DB: $DB"
makeblastdb -in "$REF" -dbtype prot -out "$DB"
echo "[INFO] Done. Files:"
ls -lh "$BASE"/ref/mannitol_db.*
