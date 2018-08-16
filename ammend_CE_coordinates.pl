#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#script to take conserved elements output by phastCons for a chromosome chunk, and ammend coordinates to that of whole chromosome (rather than within the chunk)
#assumes the file name is: spp.chr.start-end.*
#usage: perl ammend_CE_coordinates.pl --CEs in.bed --out out.bed

my $CEs;
my $out;

GetOptions(
	'CEs=s' => \$CEs,
	'out=s' => \$out,
) or die "missing input\n";

my @file = split(/\./, $CEs);
my @coor = split(/-/, $file[2]);
my $offset = $coor[0] - 1;

open (IN, "$CEs") or die;
open (OUT, ">$out") or die;

while (my $line = <IN>) {
	chomp $line;
	my @cols = split(/\t/, $line);
	my $start = $cols[1] + $offset;
	my $end = $cols[2] + $offset;
	print OUT "$file[1]\t$start\t$end\t$cols[3]\t$cols[4]\t$cols[5]\n";
}

close IN;
close OUT;

exit;
