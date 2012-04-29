#!/usr/bin/perl

# Version 2: Lösungsvorschlag aus dem Perlkochbuch

use strict;
use Data::Dumper;

my @arr1;
my @words;
my $n = 0;



open my $fh_in ,'<' , './text/lydia_1.txt' || die "Datei konnte nicht geöffnet werden.";

while (<$fh_in>) {
        $n++; 

            # g: global globale Suche (findet alle Vorkommen.
            # m: multiline behandelt Zeilen wie neue Strings.

	@words = m/[A-Za-zÖöÄäÜüß'-]+/g;  # Alle Wörter.
        #@words = m/(\b[^\Wa-zöäüß0-9_][^\WA-ZöÄÜ0-9_]*\b)/g; # Alle großgeschriebenen Wörter
        push(@arr1, @words);
}

close($fh_in);

print Dumper @arr1;
1;
