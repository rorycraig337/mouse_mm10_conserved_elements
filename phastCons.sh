#!/usr/bin/env bash

for i in mm10.chr*mfa ; do
	root=`basename $i .mfa`
	perl neutralise_species.pl --mfa $i --species mm10,rn5 --out $root.n.mfa
done

parallel -j 4 'phastCons --expected-length=45 --target-coverage=0.3 --rho=0.31 --most-conserved {= s:\.[^.]+$::;s:\.[^.]+$::; =}.most-cons.bed --msa-format FASTA {} mm10.60way.phastCons.placental.mod --no-post-probs' ::: mm10.chr*.n.mfa

for i in mm10.chr*most-cons.bed ; do
	perl ammend_CE_coordinates.pl --CEs $i --out a_$i
done

