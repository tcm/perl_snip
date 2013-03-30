#!/usr/bin/perl

use strict;
use warnings;

use Path::Class;

my $rootdir = "proe_archiv";




# Wurzelverzeichnis anlegen.
mkdir($rootdir);

# Verzeichnisse 600 bis 6xx anlegen.
####################################
my $aaa  = 600;
my $a = 1;
my $n1 = 0;

while ( $n1 <= $a)
{ 
   my $dir = dir($rootdir, $aaa);
   mkdir($dir);

   #Verzeichnisse 6xx0 bis 6xx9 anlegen.
   #####################################
   my $b = 9;
   my $n2 = 0; 
   while ( $n2 <= $b )
   {  
      my $dir = dir($rootdir, $aaa, $aaa.$n2);
      mkdir($dir);
      

      # Verzeichnisse 6xxxxx0 bis 6xxx999 anlegen.
      # ##########################################
      my $c = 99;
      my $n3 = 0;
      
      while ( $n3 <= $c )
      {
         my $n3_string = substr("000".$n3,-3); # Führende Nullen erzeugen.
         my $dir = dir($rootdir, $aaa, $aaa.$n2, $aaa.$n2.$n3_string);
         mkdir($dir);
         $n3++;
      }

      $n2++;
   } 



   $n1++;
   $aaa++;
}

