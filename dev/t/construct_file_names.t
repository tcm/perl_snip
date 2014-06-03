#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use IFiles;
use DDP;

my %source_hash1 = (
 '/dir1/dir2/file10.drw' => 'CW',
 '/dir1/dir10/file6.prt' => 'WW',
 '/dir1/dir15/file7.prt' => 'WC',
 '/dir1/dir26/file5.prt' => 'CW',
 '/dir1/dir56/file2.prt' => 'W?'
 
);

my %source_hash2 = (
'/dir1/dir2/file10.drw' => 35,
'/dir1/dir10/file6.prt' => 3,
'/dir1/dir15/file7.prt' => 2,
'/dir1/dir26/file5.prt' => 16,
'/dir1/dir56/file2.prt' => 5
);

my %destination_hash1 = ();

my $obj_file = IFiles->new();
$obj_file->construct_file_names(\%source_hash1,\%source_hash2,"./destination_dir",\%destination_hash1);

is($destination_hash1{'/dir1/dir2/file10.drw.35'}, "destination_dir/dir1/dir2", "Ok");
is($destination_hash1{'/dir1/dir26/file5.prt.16'}, "destination_dir/dir1/dir26", "Ok");
