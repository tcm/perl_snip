#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

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
);

my %dest_hash1;

my $obj_file = IFiles->new();
$obj_file->get_max_file_postfix(\@testset1,\%dest_hash1);

is($dest_hash1{'file7.prt'}, 2, "Ok");
is($dest_hash1{'file10.drw'}, 35, "Ok");
is($dest_hash1{'file6.prt'}, 3, "Ok");
