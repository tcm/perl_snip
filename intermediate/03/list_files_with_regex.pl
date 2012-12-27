#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $directory = "/etc";
my $eingabe;

do
{  
   print "> ";
   $eingabe = <STDIN>;
   chomp($eingabe);
   my @all_files = <$directory/*>;

   eval 
   { 
   my @filtered_files = grep /$eingabe/, @all_files; 
   print Dumper @filtered_files;
   };
}
while ($eingabe);
