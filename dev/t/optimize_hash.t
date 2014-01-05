#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use IFiles;
use DDP;

my %source_hash1 = (
 'file10.drw' => 'C',
 'file6.prt' => 'W',
 'file7.prt' => 'W',
 'file5.prt' => 'C',
 'file2.prt' => 'W'
 
);

my %dest_hash1 = (
'file10.drw' => 35,
'file6.prt' => 3,
'file7.prt' => 2,
'file5.prt' => 16,
'file2.prt' => 5
);

my %dest_hash2 = (
'file10.drw' => 34,
'file6.prt' => 2,
'file7.prt' => 1,
'file5.prt' => 15,
'file2.prt' => 4
);


my $obj_file = IFiles->new();
$obj_file->optimize_hash(\%source_hash1,\%dest_hash1,\%dest_hash2);

is(keys %dest_hash1, 2, "Ok");
is(keys %dest_hash2, 2, "Ok");
