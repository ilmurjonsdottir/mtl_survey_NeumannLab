#!/usr/bin/env python3
import csv
from collections import defaultdict

PRES = "out/summary/mannitol_gene_presence_downsampled.tsv"
OUT_GENE = "out/summary/mannitol_species_gene_prevalence.tsv"
OUT_PATH = "out/summary/mannitol_species_pathway_prevalence.tsv"

def main():
    with open(PRES, newline="") as f:
        r = csv.DictReader(f, delimiter="\t")
        genes = [c for c in r.fieldnames if c not in ("species", "sample", "ST")]
        rows = list(r)

    tot = defaultdict(int)
    pos = {g: defaultdict(int) for g in genes}

    def has(row, g):
        return row.get(g, "0") == "1"

    # Pathway logic (edit to match your definition)
    path_defs = {
        "classical_mtlA_and_mtlD": lambda row: has(row, "mtlA") and has(row, "mtlD"),
        "classical_mtlA_mtlD_mtlF": lambda row: has(row, "mtlA") and has(row, "mtlD") and has(row, "mtlF"),
        "any_mannitol_gene": lambda row: any(has(row, g) for g in genes),
        "enterococcus_like_mtlA_like": lambda row: has(row, "mtlA_like"),
    }
    path_pos = {k: defaultdict(int) for k in path_defs}

    for row in rows:
        sp = row["species"]
        tot[sp] += 1
        for g in genes:
            if has(row, g):
                pos[g][sp] += 1
        for k, fn in path_defs.items():
            if fn(row):
                path_pos[k][sp] += 1

    species = sorted(tot.keys())

    with open(OUT_GENE, "w", newline="") as f:
        w = csv.writer(f, delimiter="\t")
        w.writerow(["species", "n_genomes"] + [f"{g}_pct" for g in genes])
        for sp in species:
            n = tot[sp]
            w.writerow([sp, n] + [f"{100.0*pos[g][sp]/n:.2f}" if n else "NA" for g in genes])

    with open(OUT_PATH, "w", newline="") as f:
        w = csv.writer(f, delimiter="\t")
        w.writerow(["species", "n_genomes"] + [f"{k}_pct" for k in path_defs.keys()])
        for sp in species:
            n = tot[sp]
            w.writerow([sp, n] + [f"{100.0*path_pos[k][sp]/n:.2f}" if n else "NA" for k in path_defs.keys()])

    print("[INFO] Wrote:", OUT_GENE)
    print("[INFO] Wrote:", OUT_PATH)

if __name__ == "__main__":
    main()
