# mtl_survey_NeumannLab
This repository contains a reproducible pipeline to survey mannitol metabolism capacity across large collections of bacterial genomes using both genome quality filtering and sequence-level gene detection.


Overview
This repository contains a reproducible, HPC-compatible pipeline to survey the capacity for mannitol metabolism across large collections of bacterial genomes. The workflow filters public genomes for assembly quality, predicts proteomes, performs sequence-based detection of mannitol utilization genes, and summarizes gene prevalence at both the genome and species level.

The pipeline is designed for large-scale comparative genomics and is suitable for evaluating species-wide trends, strain-level variability, and pathway completeness for mannitol metabolism.

The workflow consists of the following major steps:

Genome collection

Public genomes are downloaded for selected bacterial species.

Assemblies are organized by species.

Quality filtering using MLST

Genomes are screened for completeness using MLST locus presence.

Assemblies lacking a full complement of MLST loci are excluded to remove fragmented genomes.

Balanced genome selection

Non-fragmented genomes are downsampled to a maximum number per species to avoid sampling bias.

Proteome prediction

Protein-coding genes are predicted for each genome using Prodigal.

Sequence-based gene detection

Predicted proteomes are searched using BLASTP against a curated reference set of mannitol metabolism proteins.

Hits are filtered using stringent e-value and coverage thresholds.


Mannitol Metabolism Genes Surveyed

The pipeline focuses on canonical and related mannitol metabolism components, including:

mtlA – Mannitol-specific PTS transporter (EIICB/EIICBA)

mtlD – Mannitol-1-phosphate dehydrogenase

mtlF – PTS IIA component

mtlR – Transcriptional regulator of the mannitol operon

mtlA-like / polyol PTS components – Alternative or divergent PTS systems (e.g., Enterococcus spp.)

Reference protein sequences are curated from well-annotated strains and used to detect homologs across surveyed genomes.
