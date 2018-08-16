# mouse_mm10_conserved_elements

Pipeline for identification of CEs/CNEs for the mm10 mouse genome, to be used for population genetics. Using phastCons and UCSC alignments, but masking mouse and rat sequences to avoid ascertainment bias from mouse/rat divergence.

File of CNEs can be produced by running: bash pipeline.sh

Requirements:

PHAST v1.4 - https://github.com/CshlSiepelLab/phast

bedtools v2.26.0 - https://github.com/arq5x/bedtools2

BioPerl modules AlignIO and SimpleAlign
