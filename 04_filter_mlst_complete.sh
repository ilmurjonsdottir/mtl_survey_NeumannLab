#!/usr/bin/env bash
set -euo pipefail

# Filter genomes by MLST locus completeness.
# Keeps genomes that have allele calls for all MLST loci (ST can be '-' and is ignored).
#
# Inputs:
#   manifest/genomes.tsv
#   out/mlst/<sample>.mlst.tsv
#
# Outputs:
#   out/filtered/genomes_mlst_nonfragmented.tsv
#   out/summary/mlst_nonfragmented_summary.tsv

source scripts/00_vars.sh

MANIFEST="$MANIFEST_DIR/genomes.tsv"
OUT_KEEP="$OUT_FILTER/genomes_mlst_nonfragmented.tsv"
SUMMARY="$OUT_SUMMARY/mlst_nonfragmented_summary.tsv"

[[ -s "$MANIFEST" ]] || die "Missing manifest: $MANIFEST"

echo "[INFO] Writing: $OUT_KEEP"
echo -e "species	sample	fasta	ST" > "$OUT_KEEP"

tail -n +2 "$MANIFEST" | while IFS=$'\t' read -r SPECIES SAMPLE FASTA; do
  ML="$OUT_MLST/${SAMPLE}.mlst.tsv"
  [[ -s "$ML" ]] || continue

  LINE=$(grep -v '^#' "$ML" | head -n1 || true)
  [[ -n "${LINE:-}" ]] || continue

  ST=$(echo "$LINE" | awk '{print $3}')
  LOCI=$(echo "$LINE" | cut -d' ' -f4-)

  # Only require allele calls at each locus; ST can be '-'.
  if echo "$LOCI" | grep -qE '(^|[[:space:]])-|\?|(^|[[:space:]])-$'; then
    continue
  fi

  echo -e "${SPECIES}	${SAMPLE}	${FASTA}	${ST}" >> "$OUT_KEEP"
done

echo "[INFO] Building summary: $SUMMARY"
echo -e "species	total_genomes	non_fragmented_MLST	fraction_non_fragmented" > "$SUMMARY"

awk 'NR>1 {all[$1]++} END {for (s in all) print s, all[s]}' "$MANIFEST" | sort > "$OUT_SUMMARY/_all.tmp"
awk 'NR>1 {good[$1]++} END {for (s in good) print s, good[s]}' "$OUT_KEEP" | sort > "$OUT_SUMMARY/_good.tmp"

join -a1 -e 0 -o 1.1,1.2,2.2 "$OUT_SUMMARY/_all.tmp" "$OUT_SUMMARY/_good.tmp"   | while read -r SPECIES TOTAL GOOD; do
      FRAC=$(awk -v g="$GOOD" -v t="$TOTAL" 'BEGIN{ if (t>0) printf "%.4f", g/t; else print "NA"}')
      echo -e "${SPECIES}	${TOTAL}	${GOOD}	${FRAC}" >> "$SUMMARY"
    done

rm -f "$OUT_SUMMARY/_all.tmp" "$OUT_SUMMARY/_good.tmp"

echo "[INFO] Done."
echo "[INFO] Preview summary:"
column -t "$SUMMARY" | head
