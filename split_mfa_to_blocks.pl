#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);
use Bio::AlignIO;
use Bio::SimpleAlign;

#script to split a multiple fasta alingment to blocks, splitting where the reference species sequence is unaligned for a set number of bases
#options are block_size (number of bases per block), interval (total region size around block boundary to search for unaligned sequence), unaligned (number of bases that permits a split)
#works with phast style "*" characters, but as these are not recognised by bioperl warnings will be produced, it is recommended to direct stderr to a log file
#assumes file name contains chromosome name before first "." character
#usage: perl split_mfa_to_blocks.pl --mfa in.mfa --block_size 10000000 --interval 100000 --unaligned 1000


my $mfa;
my $block_size;
my $interval;
my $unaligned;

GetOptions(
	'mfa=s' => \$mfa,
	'block_size=i' => \$block_size,
	'interval=i' => \$interval,
	'unaligned=i' => \$unaligned,
) or die "missing input\n";

my @file = split (/\./, $mfa);
my $chr = $file[1];

my $str = Bio::AlignIO->new(-file => "$mfa",
	-format => "fasta");
my $aln = $str->next_aln();
my $len = $aln->length();
if ($len < ($block_size + ($block_size/2)) ) { #chromosome is less than block size + half block size, will not be split
	system(`cp $mfa $file[0].$chr.1-$len.mfa`);
}
else {
	my $pos = 1;
	my $division = $len / $block_size;
	my $rounded = sprintf "%.0f", $division;
	print "$chr\t$division\t$rounded\n";
	my $split_count = 0;
	my $unaligned_count = 0;
	my $start = $block_size - ($interval/2);
	my $stop = $block_size + ($interval/2);
	my $split_pos_start = 1;
	until ($pos == $len) { #loop through alignment
		if ( ($pos > $start) and ($pos < $stop) ) { #within split region, start checking for unaligned sequence
			my @alignment;
			my $spp_count = 0;
			my $focal_base;
			foreach my $seq ($aln->each_seq) { #loop through each sequence
				$spp_count++;
				my $base = $seq->subseq($pos, $pos);
				push @alignment, $base; #make array of bases at alignment column 
				if ($spp_count == 1) {
					$focal_base = $base;
				}
			}
			my $unaligned_spp1 = grep { $_ eq '-' } @alignment; #get tally of unaligned species
			my $unaligned_spp2 = grep { $_ eq '*' } @alignment; # '*' is a special gap character used by phast
			my $unaligned_spp = $unaligned_spp1 + $unaligned_spp2;
			if ($unaligned_spp == ($spp_count - 1) ) { #assumes no gaps in reference, will die if gaps are found
				$unaligned_count++;
				if ($focal_base eq "-") {
					die "currently script doesn't work with gaps in reference\n";
				}
			}
			else {
				$unaligned_count = 0;
			}
			if ($unaligned_count > $unaligned) { #mfa can be split here
				my $split_pos_stop = $pos - ($unaligned/2);
				my $aln_out = Bio::AlignIO->new(-file => ">$file[0].$chr.$split_pos_start-$split_pos_stop.mfa",
					-format => 'fasta');
				my $aln_slice = $aln->slice($split_pos_start,$split_pos_stop);
				$aln_out->write_aln($aln_slice);
				$split_pos_start = $split_pos_stop + 1;
				$start = $start + $block_size;
				$stop = $stop + $block_size;
				$unaligned_count = 0;
				$split_count++;
			}
		}
		$pos++;
		if ($pos > $stop) {
			die "failed to find region suitable for split, try a larger interval\n";
		}
		if ($split_count == ($rounded - 1) ) {
			my $new_start = $pos - ($unaligned/2);
			my $aln_out = Bio::AlignIO->new(-file => ">$file[0].$chr.$new_start-$len.mfa",
				-format => 'fasta');
			my $aln_slice = $aln->slice($new_start,$len);
			$aln_out->write_aln($aln_slice);
			last;	
		}
	}
}

exit;

