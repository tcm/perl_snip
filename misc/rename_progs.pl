#!/usr/bin/perl

#(jb) 29.01.2013
#perl2exe_include "Path/Class/Entity.pm";
#perl2exe_include "File/Glob.pm";

use strict;
use warnings;

use Path::Class;
use File::Copy;

# Quell-Files festlegen.
my @filtered_files = <*.ARC>;

# Zielverzeichnis
my $dir = "neu";
my $filename_found;

# Alle Files komplett einlesen.
foreach my $file (@filtered_files)
{

   open my $fh, '<', $file || die "Cannot open $file.\n";
   print "File: $file\n";

   while ( <$fh> )
   {
       if ( /\w+\.WPD/ )  # Nach dem Filenamen m Programm suchen.
       {
       $filename_found = "${^MATCH}"; # Match anzeigen.  
       print "Matched: |<$filename_found>|\n"; }

       }
   close $fh;

   my $dest_path = file($dir,$filename_found); # Ziel-Filenamen festlegen.
   print "$dest_path\n\n";
   mkdir($dir);

   copy($file, $dest_path) ; # Files mit neuem Namen kopieren.
}
