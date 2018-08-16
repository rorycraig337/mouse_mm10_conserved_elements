#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#script to convert UCSC mm10 chromosome names to ENSEMBL mm10 names for BED6 file
#usage: perl UCSC_to_ENSEMBL_names.pl --in UCSC.bed --out ENSEMBL.bed

my $in;
my $out;

GetOptions(
	'in=s' => \$in,
	'out=s' => \$out,
) or die "missing input\n";

open (IN, "$in") or die;
open (OUT, ">$out") or die;

while (my $line = <IN>) {
	chomp $line;
	my @cols = split(/\t/, $line);
	my $ucsc = $cols[0];
	my $ensembl;
	if ( ($ucsc =~ /^chrUn/) or ($ucsc =~ /random/) ) {
		my @ucsc_cols = split(/_/, $ucsc);
		$ensembl = "$ucsc_cols[1].1";
	}
	elsif ($ucsc eq "chrM") {
		$ensembl = "MT";
	}
	else {
		$ensembl = substr $ucsc, 3;
	}
	print OUT "$ensembl\t$cols[1]\t$cols[2]\n";
}

close IN;
close OUT;

exit;
