#!/usr/bin/perl

# Test comment.
use strict;
use HelperFunc;

my $s = "z0123";
my $i;

# Ohne Umwandlung in Integer
print $s + 10;
print "\n";

# Mit Umwandlung in Integer
$i = atoi($s);
print $i + 10;
print "\n";

print printme("The quick brown fox jumps over the lazy dog!");
#print metnirp("The quick brown fox jumps over the lazy dog!");
