#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use IFiles;
use DDP;

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

my %source_hash1 = ( 'file7.prt' =>  2,
                     'file2.prt' =>  1,
                     'file3.prt' =>  1,
                     'file5.prt' =>  1,
                     'file1.prt' =>  1,
                     'file4.prt' =>  1,
                     'file9.prt' =>  1,
                     'file8.prt' =>  1,
                     'file10.drw' =>  2,
                     'file6.prt' =>  3
                     );

my @dest_array1;

my $obj_file = IFiles->new();
$obj_file->filter_candidate_files_by_count(\@testset1,\%source_hash1,\@dest_array1);

my $count = @dest_array1;
is($count, 7, "Ok");
