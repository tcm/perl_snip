#!/usr/bin/perl

use strict;
use warnings;

use Cwd;


my @files = <*>;

my $wdir = cwd();

foreach my $entry (@files)
{
   print "    $wdir$entry\n";
}

