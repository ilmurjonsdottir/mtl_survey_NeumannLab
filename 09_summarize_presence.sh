#!/usr/bin/env bash
set -euo pipefail

# Build per-genome presence/absence table from BLAST outputs.
# Output: out/summary/mannitol_gene_presence_downsampled.tsv

source scripts/00_vars.sh

LIST="$OUT_FILTER/genomes_mlst_nonfragmented_downsampled.tsv"
REF="$BASE/ref/mannitol_refs.faa"
OUT="$OUT_SUMMARY/mannitol_gene_presence_downsampled.tsv"
GENE_LIST="$OUT_SUMMARY/mannitol_genes.list"

[[ -s "$LIST" ]] || die "Missing list: $LIST"
[[ -s "$REF" ]] || die "Missing reference: $REF"

grep "^>" "$REF" | sed 's/^>//' | cut -d'|' -f1 | sort -u > "$GENE_LIST"

HEADER="species	sample	ST"
while read -r G; do
  HEADER="${HEADER}	${G}"
done < "$GENE_LIST"
echo -e "$HEADER" > "$OUT"

tail -n +2 "$LIST" | while IFS=$'\t' read -r SPECIES SAMPLE FASTA ST; do
  BL="$OUT_HITS/${SAMPLE}.mannitol.blast6"

  declare -A HAS
  while read -r G; do
    HAS["$G"]=0
  done < "$GENE_LIST"

  if [[ -s "$BL" ]]; then
    while read -r QID SID PIDENT LENGTH MISM GAP QSTART QEND SSTART SEND EVALUE BITS QLEN SLEN; do
      GENE=$(echo "$SID" | cut -d'|' -f1)
      grep -qx "$GENE" "$GENE_LIST" || continue

      COVQ=$(awk -v l="$LENGTH" -v q="$QLEN" 'BEGIN{ if (q>0) printf "%.3f", l/q; else print 0 }')
      COVS=$(awk -v l="$LENGTH" -v s="$SLEN" 'BEGIN{ if (s>0) printf "%.3f", l/s; else print 0 }')
      OK=$(awk -v cq="$COVQ" -v cs="$COVS" 'BEGIN{ if (cq>=0.6 || cs>=0.6) print 1; else print 0 }')
      [[ "$OK" -eq 1 ]] || continue

      HAS["$GENE"]=1
    done < "$BL"
  fi

  LINE="${SPECIES}	${SAMPLE}	${ST}"
  while read -r G; do
    LINE="${LINE}	${HAS[$G]}"
  done < "$GENE_LIST"

  echo -e "$LINE" >> "$OUT"
  unset HAS
done

echo "[INFO] Wrote: $OUT"
