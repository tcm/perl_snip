#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use Template;
use Data::Dumper;
use English;

my @record;
my @AoA;
############################################
# Read data from CSV-File and store into an
# Array of Arrays.
############################################
while (<>) {
    chomp;
    @record = split (/,/,$ARG);
    push @AoA, [ @record ];
}

#print Dumper (@AoA);

my $tt = Template->new(
    {
        INCLUDE_PATH => "$Bin",
        INTERPOLATE  => 1,
    }
) || die "$Template::ERROR\n";

################################################
# Transform data from an Array-Reference into
# a CSV-File.
################################################
$tt->process('main.tt', { recordset => \@AoA })
  || die $tt->error;
