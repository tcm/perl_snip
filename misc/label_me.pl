#!/usr/bin/perl

use strict;
use warnings;

use Text::CSV;
use Data::Dumper;



my @rows;
my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                or die "Cannot use CSV: ".Text::CSV->error_diag ();
 
#open my $fh_in, "<:encoding(utf8)", "adressen.csv" or die "test.csv: $!";
open my $fh_in, "<", "adressen.csv" or die "test.csv: $!";
open my $fh_out, ">", "labels.txt" or die "labels.txt: $!";

while ( my $row = $csv->getline( $fh_in ) ) 
{
    print $fh_out "----------------------------------------------\n";
    print $fh_out "$row->[1] $row->[0]\n";
    print $fh_out "$row->[2]\n";
    print $fh_out "\n";
    print $fh_out "$row->[3] $row->[4] $row->[5]\n";
    print $fh_out "\n";
    print $fh_out "\n";
    print $fh_out "\n";
    print $fh_out "----------------------------------------------\n";
}
$csv->eof or $csv->error_diag();
close $fh_in;
close $fh_out;

1;
