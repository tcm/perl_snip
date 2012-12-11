#!/usr/bin/perl

use strict;
use warnings;

use Business::ISBN;


my $isbn13 = Business::ISBN->new('978-1-449-39309-0');

print $isbn13->group_code."\n";
print $isbn13->publisher_code."\n";


