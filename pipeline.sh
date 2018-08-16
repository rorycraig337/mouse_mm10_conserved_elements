#get 60-way mm10 referenced alignments from UCSC
rsync -avz --progress rsync://hgdownload.cse.ucsc.edu/goldenPath/mm10/multiz60way/maf/chr* ./

#get checksum and check
rsync -avz --progress rsync://hgdownload.cse.ucsc.edu/goldenPath/mm10/multiz60way/maf/md5sum.txt ./
md5sum -c md5sum.txt

#get the mod file representing phylogeny of aligned placental species
rsync -avz --progress rsync://hgdownload.cse.ucsc.edu/goldenPath/mm10/phastCons60way/mm10.60way.phastCons.placental.mod ./

#get mm10 annotation GTF from Ensembl and decompress
rsync -avz --progress rsync://ftp.ensembl.org/ensembl/pub/release-93/gtf/mus_musculus//Mus_musculus.GRCm38.93.gtf.gz ./
gunzip Mus_musculus.GRCm38.93.gtf.gz

#format alignments for phastCons
#leading_Nblock_for_MAF.pl adds bases for reference species before first MAF block, keeps coordinates consistent between MAF and FASTA
#msa_view command converts MAF to FASTA, removes non-placental species, and strips all gaps from mm10 (these are ignored by phastCons anyway)
#format_msa_view.pl deletes space in FASTA headers and changes "*" gap character to "-"
#split_mfa_to_blocks.pl splits large chromosomes (>90Mb here) into ~60Mb chunks at regions with no alignment, as phastCons doesn't like chromosomes >100Mb
bash format_alignments.sh

#get conserved elements 
#neutralise_species.pl masks all mouse and rat sequences with N
#phastCons identifies elements, using standard UCSC parameters
#ammend_CE_coordinates.pl fixes element coordiantes that are offset due to alignment chunks
nohup bash phastCons.sh &

#concatenate all coordinate-corrected CEs
cat a_mm10*most-cons.bed | sort -k1,1 -k2n,2n > mm10_CEs.bed

#extract exonic regions from mm10 GTF
perl extract_exon_biotypes.pl --biotypes ensembl_mm10_exonic.txt --gtf Mus_musculus.GRCm38.93.gtf --out ens_mm10_exons.gtf
sort -k1,1 -k4n,4n ens_mm10_exons.gtf | bedtools merge -i stdin > ens_mm10_exons.bed

#convert UCSC chromosome names to ENSEMBL
perl UCSC_to_ENSEMBL_names.pl --in mm10_CEs.bed --out ens_mm10_CEs.bed

#remove any CEs with overlap with exons
bedtools intersect -v -a ens_mm10_CEs.bed -b ens_mm10_exons.bed > ens_mm10_CNEs.bed

#clean up directory
rm *mfa
rm *most-cons*
