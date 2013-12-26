#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use IFiles;
use Data::Dumper;

my @testset1 = qw(
file10.drw.34
file10.drw.35
file1.prt.1
file2.prt.1
file3.prt.1
file4.prt.1
file5.prt.1
file6.prt.1
file6.prt.2
file6.prt.3
file7.prt.1
file7.prt.2
file8.prt.8
file9.prt.9
);

my %dest_hash1;
my $obj_file = IFiles->new();

$obj_file->count_candidate_files(\@testset1,\%dest_hash1);

is($dest_hash1{'file6.prt'}, 3, "Ok");
is($dest_hash1{'file7.prt'}, 2, "Ok");
is($dest_hash1{'file10.drw'}, 2, "Ok");
