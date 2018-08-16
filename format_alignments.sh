#!/usr/bin/env bash

for i in chr*.maf.gz ; do
        root=`basename $i .maf.gz`
        gunzip $i
	perl leading_Nblock_for_MAF.pl --maf $root.maf --out mm10.$root.maf
	gzip $root.maf
        msa_view mm10.$root.maf --in-format MAF --out-format FASTA --order mm10,rn5,dipOrd1,hetGla2,cavPor3,speTri2,oryCun2,ochPri2,hg19,panTro4,gorGor3,ponAbe2,nomLeu2,rheMac3,papHam1,calJac3,saiBol1,tarSyr1,micMur1,otoGar3,tupBel1,susScr3,vicPac1,turTru2,oviAri1,bosTau7,felCat5,canFam3,ailMel1,equCab2,myoLuc2,pteVam1,eriEur1,sorAra1,loxAfr3,proCap1,echTel1,triMan1,dasNov3,choHof1,anoCar2,chrPic1,danRer7,fr3,gadMor1,galGal4,gasAcu1,latCha1,macEug2,melGal1,melUnd1,monDom5,oreNil2,ornAna1,oryLat2,petMar1,sarHar1,taeGut1,tetNig2,xenTro3 --exclude -l anoCar2,chrPic1,danRer7,fr3,gadMor1,galGal4,gasAcu1,latCha1,macEug2,melGal1,melUnd1,monDom5,oreNil2,ornAna1,oryLat2,petMar1,sarHar1,taeGut1,tetNig2,xenTro3 --gap-strip 1 > mm10.$root.mfa
	rm mm10.$root.maf
	perl format_msa_view.pl	--mfa mm10.$root.mfa --out mm10.$root.f.mfa
	rm $root.mfa
	perl split_mfa_to_blocks.pl --mfa mm10.$root.f.mfa --block_size 60000000 --interval 10000000 --unaligned 1000
	rm $root.f.mfa
done
