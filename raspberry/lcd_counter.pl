#!/usr/bin/perl

use strict;
use warnings;

use lib '/home/pi/scripts/';
use LCD;

deleteAllDigits;

foreach my $n ( 0 .. 99 ) {
	
	my $nstr = substr("00".$n,-2); # Ziffern mit führenden Nullen zusammenbauen.
	showTwoDigits($nstr);
}


exit 0;

