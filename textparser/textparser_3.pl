#!/usr/bin/perl

# Version 3: Lösungsvorschlag aus dem Perlkochbuch
# Plus wir bauen einen Hash auf, in dem die Anzahl der Wörter
# gezählt wird. Wir speichen den Hash in einem File.

use strict;
use Storable;
use Data::Dumper;

my %hash1;
my @words;
my $n = 0;
my $hashref;


open my $fh_in ,'<' , './text/elb_bibel.txt' || die "Datei konnte nicht geöffnet werden.";

while (<$fh_in>) {
        $n++;

            # g: global globale Suche (findet alle Vorkommen).
            # m: multiline behandelt Zeilen wie neue Strings.

#@words = m/[A-Za-zÖöÄäÜüß'-]+/g; # Alle Wörter Muster1.
@words = m/\b([A-Za-zÖöÄäÜüß'-]+)\b/g; # Alle Wörter Muster2.
        foreach my $word (@words) { # Hash mit Wortanzahl bilden.
           $hash1{$word}++;
        }
}

close($fh_in);

store \%hash1, 'hash1.dat'; # Hash in File speichern
%hash1 = undef; # ...und löschen.
#print Dumper %hash1;


$hashref = retrieve('hash1.dat'); # Hash wieder lesen
                                  # und ausgeben.
print Dumper $hashref;
print "$n Zeilen verarbeitet.\n";
1;
