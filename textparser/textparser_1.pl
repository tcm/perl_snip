#!/usr/bin/perl

# Version 1: Eigenlösung nach eigener Idee.

use strict;
use Data::Dumper;

my @arr1;
my $n = 0;


open my $fh_in ,'<' , './text/lydia_1.txt' || die "Datei konnte nicht geöffnet werden.";

while (<$fh_in>) {
        $n++; 
 
        s/[,\.–"»«]/ /g;          # 1. Alle störenden Zeichen in <SPACE> umwandeln.
        push(@arr1, split(/ /));  # 2. Zeile für Zeile nach Leerzeichen aufsplitten.
}

close($fh_in);

print Dumper @arr1;
1;
