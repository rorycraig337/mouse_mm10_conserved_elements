#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#script to take mm10 GTF file and a list of exonic biotypes, and output only the exons for these biotypes
#usage: perl extract_exon_biotypes.pl --biotypes in.txt --gtf mm10.gtf --out mm10_exons.gtf

my $biotypes;
my $gtf;
my $out;

GetOptions(
	'biotypes=s' => \$biotypes,
	'gtf=s' => \$gtf,
	'out=s' => \$out,
) or die "missing input\n";

my %biotype;

open (IN1, "$biotypes") or die;

while (my $class = <IN1>) {
	chomp $class;
	$biotype{$class} = 1;
}

close IN1;

open (IN2, "$gtf") or die;
open (OUT, ">$out") or die;

while (my $line = <IN2>) {
	chomp $line;
	unless ($line =~ /^#/) {
		my @cols = split(" ", $line);
		if ($cols[2] eq "exon") {
			my $match = 0;
			foreach my $col (@cols) {
				if ($match == 1) { #this column contains the biotype
					my $strip = substr $col, 1, -2; #strips commas and semi-colon
					if (exists $biotype{$strip}) {
						print OUT "$line\n";
					}
					last; #don't read anymore columns
				}
				if ($col eq "gene_biotype") { #next column contains the biotype
					$match++; 
				}
			}
		}
	}
}

close IN2;
close OUT;

exit;
