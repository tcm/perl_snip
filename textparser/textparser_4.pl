#!/usr/bin/perl

# Version 4. Lösungsvorschlag aus dem Perlkochbuch
# Plus wir bauen einen Hash auf, in dem die Anzahl der Wörter
# gezählt wird. Wir speichen den Hash in einer SQLite-Datenbank.
use strict;
use DBI;
use Data::Dumper;
use FindBin '$Bin';

my %hash1;
my @words;
my $word;
my $count;
my $n = 0;


my $dbargs = {AutoCommit => 0, PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=words.db", "", "", $dbargs);

open my $fh_in, '<' , '$Bin/text/elb_bibel.txt' || die "Datei konnte nicht geöffnet werden.";

while (<$fh_in>) {
        $n++; 

            # g: global globale Suche (findet alle Vorkommen).
            # m: multiline behandelt Zeilen wie neue Strings.

	#@words = m/[A-Za-zÖöÄäÜüß'-]+/g;          # Alle Wörter Muster1.
	@words = m/\b([A-Za-zÖöÄäÜüß'-]+)\b/g;     # Alle Wörter Muster2.
        foreach  my $word (@words) {               # Hash mit Wortanzahl bilden.
           $hash1{$word}++;
        }
}

close($fh_in);

my $sth = $dbh->prepare(q{INSERT INTO wordcount (word,count) VALUES (?,?)});
while (($word,$count) = each (%hash1)) {
	#print "$word $count\n";

	# eine Zeile einfuegen
       $sth->execute($word,$count);
	$sth->finish;
}
$dbh->commit;

# Zeilen ausgeben
my ($word, $count) = "";
my $res = $dbh->selectall_arrayref("SELECT word,count FROM wordcount ORDER BY count;");
foreach my $row (@$res) {
  ($word, $count) = @$row;
    print("Word: $word - $count\n");
}

if ($dbh->err()) { die "$DBI::errstr\n"; }
$dbh->disconnect();


print "$n Zeilen verarbeitet.\n";
1;
