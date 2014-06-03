#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use IFiles;
use DDP;

my @testset1 = qw(
file6.prt.1
file6.prt.3
file10.drw.35
file7.prt.1
file10.drw.34
file6.prt.2
file7.prt.2
file6.prt.5
);

my %filter_hash1 = ( 'file6.prt' => 5, 'file7.prt' => 2, 'file10.drw' => 35 ); 
my @dest_array1;

my $obj_file = IFiles->new();
$obj_file->filter_hash_values_from_array(\@testset1, \%filter_hash1, \@dest_array1);

my $count = @dest_array1;

is($count, 5,"Ok");
