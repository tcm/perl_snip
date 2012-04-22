#!/usr/bin/perl -w 
# Listing 9 
# aus Toolbox 5/2009
#
use strict;
use warnings;

my %ringe = qw(Elben 3 Zwerge 7 Menschen 9);

#Call by value
my %copy_copy_ringe = MaxNumberOfRings(%ringe);
# Destruktive Routine, call by reference
my $returncode = MaxNumberOfRings_Ref(\%ringe);


print $ringe{'Hobbits'} . "\n";



sub MaxNumberOfRings
{
   my %copy_ringe = @_;

   foreach my $race(keys %copy_ringe)
   {
      print $copy_ringe{$race} . " Ringe den $race.\n";
   }
   # Stand Ende 1420 Auenland-Zeitrechnung
   $copy_ringe{'Zwerge'} = 0;
   $copy_ringe{'Hobbits'} = 1;
   $copy_ringe{'Menschen'} = 0;

   return (%copy_ringe);
}



sub MaxNumberOfRings_Ref
{
   my $ref_ringe = shift;

   foreach my $race(keys %$ref_ringe)
   {
      print $$ref_ringe{$race} . " Ringe den $race.\n";
   }
   # Stand Ende 1420 Auenland-Zeitrechnung
   $$ref_ringe{'Zwerge'} = 0;
   $$ref_ringe{'Hobbits'} = 1;
   $$ref_ringe{'Menschen'} = 0;

   return (1); 
}


