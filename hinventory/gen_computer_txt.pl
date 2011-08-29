############################################################
#  Erzeugt die 'computer.txt' für 'hinventory.vbs'
#  aus der Windows-Browselist für die Arbeitsgruppe/Domäne.
#
# (jb) 2011
############################################################

use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Getopt::Std;

my $bl_datei = "blacklist.txt";
my $ziel_datei_bak = "computer_orig.txt";
my $ziel_datei = "computer.txt";

my %blacklist;
my %lastrun;

my @hostlist;
my $hostkey;
my %opts;

my $n = 0;

getopts('cdh', \%opts);


if (defined $opts{h}) {
	print "gen_computer_txt.pl [-c] [-d] [-h]\n\n";
	print "-h Hilfe\n";
	print "-d Diff zur Referenz-Datei erzeugen ($ziel_datei_bak).\n";
	print "-c Kopie von '$ziel_datei' nach '$ziel_datei_bak'.\n";
	exit 1;
}



#############################
# Hash für Diff-Run erzeugen.
#############################
if (defined $opts{d}) {
	print "Diff-Run...\n";

	##########################################################
	# Lookup-Hash aus computer_orig.txt-File generieren.
	###########################################################
	open my $zielb_fh, '<', $ziel_datei_bak || die "$ziel_datei_bak konnte nicht geoeffnet werden.\n"; # Die Datei enthält die Ausnahmen.

	while (<$zielb_fh>) {
		chomp;
		$lastrun{$_} = 'Do not scan.';
	}
	close ($zielb_fh);
	
} 




####################################################
# Lookup-Hash aus blacklist-File generieren.
####################################################
open my $bl_fh, '<', $bl_datei || die "$bl_datei konnte nicht geoeffnet werden.\n"; # Die Datei enthält die Ausnahmen.

while (<$bl_fh>) {
	chomp;
	$blacklist{$_} = 'Do not scan.';
}
close ($bl_fh);
# print Dumper %blacklist;

####################################################
# Die Ausgabe für das Kommando 'net view' auslesen
# und ein Textfile erzeugen. Rechner aus der 
# Blacklist werden weggelassen.
####################################################
open my $readme_fh , "net view |" || die "Fehler bei fork: $!\n";


open my $ziel_fh, '>', $ziel_datei || die "$ziel_datei konnte nicht geoeffnet werden.\n"; # Die Datei, die für hinventory.vbs erzeugt werden muss.
while (<$readme_fh>) {

	if (/^\\\\/) {                                       # Beginnt die Zeile mit 2 Backslashes?

		@hostlist =  m/\b([A-Za-z0-9-_]+)\b/;        # Nur den Rechnernamen ohne Backslashes herauslösen.
		# print Dumper @hostlist;
		foreach my $host (@hostlist) {               # Iterieren über das Array, um in das Textfile zu schreiben.
			
			unless (exists ($blacklist{$host}) ) {   # 1. Wenn kein Eintrag in der Blacklist existiert,
                        
				if (defined $opts{d}) {          # 2. Diff-Run?
					
					############
					# Diff-Run
					############
					unless (exists ($lastrun{$host}) ) { # Wenn kein Eintrag vom letzten Lauf existiert,
						 $n++;
						 print $ziel_fh "$host\n";   # ... Eintrag in das File schreiben.
					}
					
				} else {
					$n++;
					print $ziel_fh "$host\n";    # ... Eintrag in das File schreiben.
				}
			}				
	} 
		
}

}
close($readme_fh);
close($ziel_fh);


print "computer.txt generated...\n";
print "$n entries written...\n";

##################################
# File-Kopie für Diff-Run anlegen.
##################################
if (defined $opts{c}) {
	print "$ziel_datei copied to $ziel_datei_bak...\n";
	copy($ziel_datei,$ziel_datei_bak) or die "Copy failed: $!"; # Sicherheitskopie anlegen.
}

1;
