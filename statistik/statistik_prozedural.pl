#!/usr/bin/perl

# Statistik-Funktionen: prozedural
# 
# 

use strict;
use warnings;

use Data::Dumper;
use List::Util qw(sum);

my @arr1 = (1,1,1,2,3,4,5,5,5,6,6);
my @arr2 = (1,1,1,2,3,4,5,5,5,6,6,7);
my @arr3 = (1.2,1.25,0.667);

print &arith_avg( \@arr1 )."\n";

print &median( \@arr1 )."\n";
print &median( \@arr2 )."\n";

print &graph_avg( \@arr3 )."\n";





# Arithmetisches Mittel
#
#  Parameter: Referenz auf das Array
sub arith_avg
{
   my $array_ref = shift;

   my $anzahl =  scalar @{ $array_ref }; # Anzahl der Elemente bestimmen.
   my $summe = sum @$array_ref;          # Aufsummieren.
   return $summe / $anzahl;
}


# Mitte der Werte (Median)
# Feld muss sortiert sein.
#
#  Parameter: Referenz auf das Array
sub median
{
   my $array_ref = shift;

   my $anzahl =  scalar @{ $array_ref };   # Anzahl der Elemente bestimmen.

   if ( $anzahl % 2 )                      # Falls: eine ungerade Anzahl an Elementen. 
   {
   my $index = (($anzahl + 1 ) / 2) - 1;   # Index des Elementes in der Mitte bestimmen.
   return @$array_ref[$index];  
   }
   else                                    # Falls: eine gerade Anzahl an Elementen.
   {
   my $lwert = @$array_ref[($anzahl/2)-1]; # Linker Mittelwert.
   my $rwert = @$array_ref[($anzahl/2)];   # Rechter Mittelwert.

   my $wert = 0.5 * ( $lwert + $rwert ) ;  # Die Hälfte davon.
   return $wert;
   } 
}

# Graphisches Mittel
#
# Parameter: Referenz auf das Array
sub graph_avg
{
   my $array_ref = shift;
   my $produkt = 1;
      
   my $anzahl =  scalar @{ $array_ref }; # Anzahl der Elemente bestimmen.
   foreach my $element ( @$array_ref )   # Alle Elemente miteinander multiplizieren.
   {
      $produkt *= $element;    
   }
   return $produkt ** (1/$anzahl);
}

