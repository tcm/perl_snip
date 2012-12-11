#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Spec;

my @files = <*>;

my $wdir = cwd();

foreach my $entry (@files)
{
   print "    $wdir$entry\n";
   # schöner da platformunhabhängiger
   #print "    ", File::Spec->catfile($wdir, $entry), "\n";
}

