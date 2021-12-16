#!/usr/bin/perl

use strict;
use warnings;


#print "Test\n";
&lafige;


sub lafige {
   my $j = 3;
   my $k = 7;
   my @seed =  (8, 6, 7, 5, 3, 0, 9);
   my $out;

   my $len = scalar @seed;
   for ( my $n = 0; $n < 20; $n++) {
   	for ( my $i = 0; $i < $len; $i++) {

	           #print "$i ";

		   if ( $i == 0 ) {  
		      $out = ($seed[$j - 1] + $seed[$k - 1]) % 10;

                   } elsif ($i > 0 && $i < 6 ) { 
		       $seed[$i] = $seed[$i + 1]; # shift the array

	           }
	           else {
		      $seed[$i] = $out;
                      print "$seed[$i], "; # print the result 
	           }
         }   
  } 


return 0;
}




exit 0;

