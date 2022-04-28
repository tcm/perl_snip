#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use File::Spec;
use Data::Dumper;

my @array = qw( sw1 sw2 sw3 );

my $scriptfile = File::Spec->catdir( $Bin, "gen-text-from-json.pl" );  
my $projectdir = File::Spec->catdir( $Bin, "test-parameter-a" );  

foreach my $item ( @array ) {

   system("$scriptfile -p test-parameter-a -a $item >$item.ios");

}
