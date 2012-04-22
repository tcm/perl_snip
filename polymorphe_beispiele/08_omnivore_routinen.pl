#!/usr/bin/perl -w 
# Listing 8 
# aus Toolbox 5/2009
#
use strict;
use warnings;

my %ringe = qw(Elben 3 Zwerge 7 Menschen 9);

MaxNumberOfRings(%ringe);
MaxNumberOfRings_Ref(\%ringe);

MaxNumberOfRings_Omni(%ringe);
MaxNumberOfRings_Omni(\%ringe);




sub MaxNumberOfRings
{
   my %copy_ringe = @_;

   foreach my $race(keys %copy_ringe)
   {
      print $copy_ringe{$race} . " Ringe den $race.\n";
   }
}

sub MaxNumberOfRings_Ref
{
   my $ref_ringe = shift;

   foreach my $race(keys %$ref_ringe)
   {
      print $$ref_ringe{$race} . " Ringe den $race.\n";
   }
}


sub MaxNumberOfRings_Omni
{
   use Scalar::Util qw(reftype);
   if (reftype ($_[0]) )
   {

   my $ref_ringe = shift;
   foreach my $race(keys %$ref_ringe)
   {
      print $$ref_ringe{$race} . " Ringe den $race.\n";   
   }

   }
   else
   {
    
   my %copy_ringe = @_;
   foreach my $race(keys %copy_ringe)
   {
      print $copy_ringe{$race} . " Ringe den $race.\n";
   }  

   }

}
