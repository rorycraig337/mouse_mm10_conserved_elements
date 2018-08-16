#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#script adds MAF block of only Ns for reference species if first MAF block for chromosome does not start at base 1
#this keeps coordinates consistent after MAF to FASTA conversion
#usage: perl leading_Nblock_for_MAF.pl --maf in.maf --out out.maf

my $maf;
my $out;

GetOptions(
	'maf=s' => \$maf,
	'out=s' => \$out,
) or die "missing input\n";

open (IN, "$maf") or die;
open (OUT, ">$out") or die;

my $s_count = 0;
my $first_a;
my $header = <IN>;
print OUT "$header"; #print the header

while (my $line = <IN>) {
	chomp $line;
	if ( ($line =~ /^a/) and ($s_count == 0) ) {
		$first_a = $line;
	}
	if ( ($line =~ /^s/) and ($s_count == 0) ) { #first sequence in MAF file
		$s_count++;
		my @cols = split(" ", $line);
		unless ($cols[2] == 0) {
			my $N = "N"x$cols[2];
			print OUT "\na\n";
			print OUT "$cols[0] $cols[1]     0 $cols[2] $cols[4] $cols[5] $N\n\n";
			print OUT "$first_a\n";
			print OUT "$line\n";
		}
		else {
			print OUT "\n$first_a\n";
			print OUT "$line\n";
		}
	}
	elsif ($s_count == 1) { 
		print OUT "$line\n";
	}
}

close IN;
close OUT;

exit;
