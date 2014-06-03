#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use IFiles;
use DDP;

my %source_hash1 = (
't/testdata/file10.drw' => 35,
't/testdata/file6.prt' => 3,
't/testdata/file7.prt' => 2
);

my %source_hash2 = (
't/testdata/file10.drw' => 34,
't/testdata/file6.prt' => 2,
't/testdata/file7.prt' => 1
);

my %dest_hash1;

my $obj_file = IFiles->new();
$obj_file->construct_pattern(\%source_hash1,\%dest_hash1);
$obj_file->construct_pattern(\%source_hash2,\%dest_hash1);

is($dest_hash1{'t/testdata/file10.drw'}, 'CW', "Ok");
is($dest_hash1{'t/testdata/file6.prt'}, 'WC', "Ok");
is($dest_hash1{'t/testdata/file7.prt'}, 'WW', "Ok");
