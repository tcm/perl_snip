#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;


my @results = grep  get_size($_) , @ARGV;
# oder
# my @results = grep  { -s < 1000 }, @ARGV;


sub get_size
{
   my $input = shift;

   my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
   $atime,$mtime,$ctime,$blksize,$blocks)
   = stat($input);
  
   if ($size < 1000) { return $input };
}


@results = map  "    $_", @results; 
print Dumper @results;
