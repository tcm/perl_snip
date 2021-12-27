#!/usr/bin/perl

use strict;
use warnings;

# Lagged Fibonacci Generator
# 2TAP
# (jb) Dec 2021

my @seed =  (8, 6, 7, 5, 3, 0, 9);
my @arr1 = ();

@arr1 = &lafige(\@seed, 3, 7, 10, 10);

foreach my $item (@arr1) {
   print "$item, ";
}


sub lafige {
   my ($array_ref, $j, $k, $nelements, $mod) = @_; # for seed array = reference to an array.
                                                   # element position $j = scalar.
						   # element position $k = scalar.
						   # number of elements for output $nelements = scalar.
						   # range of numbers $mode = scalar.
   my $out;
   my @arr_out = ();

   my $len = scalar @$array_ref;  # length of the seed array.

   for ( my $n = 0; $n < $nelements; $n++) {
   	for ( my $i = 0; $i < $len; $i++) {

	           #print "$i ";

		   if ( $i == 0 ) {                                               # In first iteration             
		      $out = (@$array_ref[$j - 1] + @$array_ref[$k - 1]) % $mod;  # calculate the new value.

                   } elsif ($i > 0 && $i < $len -1 ) {        # In second to last iteration 
		       @$array_ref[$i] = @$array_ref[$i + 1]; # shift the array to the left.

	           }
	           else {
		      @$array_ref[$i] = $out;               # store the new element in last position of seed array.
		      push @arr_out, @$array_ref[$i];       # store new element in output array.
	           }
         }   
  } 


return @arr_out;
}




exit 0;

