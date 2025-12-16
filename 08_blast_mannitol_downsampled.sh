#!/usr/bin/env bash
set -euo pipefail

# BLASTP each predicted proteome against the mannitol reference DB.
# Output: out/mtl_hits/<sample>.mannitol.blast6

source scripts/00_vars.sh
activate_env

LIST="$OUT_FILTER/genomes_mlst_nonfragmented_downsampled.tsv"
DB="$BASE/ref/mannitol_db"

[[ -s "$LIST" ]] || die "Missing list: $LIST"
[[ -f "${DB}.pin" || -f "${DB}.psq" ]] || die "BLAST DB not found (${DB}.*). Run scripts/07_make_mannitol_db.sh"

tail -n +2 "$LIST" | while IFS=$'\t' read -r SPECIES SAMPLE FASTA ST; do
  FAA="$OUT_PROT/$SAMPLE/${SAMPLE}.faa"
  OUTBL="$OUT_HITS/${SAMPLE}.mannitol.blast6"

  [[ -s "$FAA" ]] || { echo "[WARN] Missing proteome: $FAA"; continue; }

  if [[ -s "$OUTBL" ]]; then
    continue
  fi

  echo "[INFO] BLASTP: $SAMPLE ($SPECIES)"
  blastp     -query "$FAA"     -db "$DB"     -evalue 1e-20     -max_target_seqs 10     -num_threads 4     -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen"     > "$OUTBL"
done

echo "[INFO] BLAST complete."
