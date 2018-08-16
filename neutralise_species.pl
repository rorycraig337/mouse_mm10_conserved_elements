#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#script replaces all bases for given species with Ns, useful for neutralising sequences prior to phastCons conserved element identification
#also cleans up headers to contain only species names (required for phastCons)
#usage: perl neutralise_species.pl --mfa in.mfa --species species1,species2 --out out.mfa

my $mfa;
my @species;
my $out;

GetOptions(
	'mfa=s' => \$mfa,
	'species=s' => \@species,
	'out=s' => \$out,
) or die "missing input\n";

@species = split(/,/,join(',',@species));

open (IN, "$mfa") or die;
open (OUT, ">$out") or die;

my $mask_flag = 0;

while (my $line = <IN>) {
	chomp $line;
	if ($line =~ /^>/) {
		$mask_flag = 0;
		my @header = split /\//, $line;
		print OUT "$header[0]\n"; #print only header before "/"
		my $match = substr $header[0], 1; #remove ">"
		foreach my $target (@species) {
			if ($match eq "$target") {
				$mask_flag = 1; #following sequence needs to be masked
			}
		}
	}
	else {
		if ($mask_flag == 1) {
			$line =~ tr/A-Za-z/N/; #change all text characters to Ns
			print OUT "$line\n";
		}
		else {
			print OUT "$line\n";
		}
	}
}

close IN;
close OUT;

exit;
