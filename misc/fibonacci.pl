#!/usr/bin/perl

use Data::Dumper;

@arr1 = ( 123 , 456 );

print Dumper @arr1;


foreach $n ( 2 .. 20 )
{
   @arr1[$n] = @arr1[$n - 1] + @arr1[$n - 2]; 
}

print Dumper @arr1;
