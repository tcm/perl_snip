#!/usr/bin/perl

use strict;
use Data::Dumper;
use Getopt::Std;


my @AoA;
my $n;
my $match;
my $i = 0;
my %options; # assoziatives array fuer die uebergebenen Optionen
my $quell_datei = "<Quelldatei>";
my $ziel_datei = "<Zieldatei>";
my $header_datei =  "D:\\ics\\header.txt";

getopts('123',\%options);

# 1
# Filterung: Jahr
if(defined $options{1})
{
	$quell_datei =  "D:\\ics\\buero.ics"; 
	$ziel_datei =  "D:\\ics\\buero_2010.ics";
}

# 2
# Filterung: Urlaub
if(defined $options{2})
{
	$quell_datei =  "D:\\ics\\buero_2010.ics"; 
	$ziel_datei =  "D:\\ics\\buero_2010_urlaub.ics";
}

# 3
# Filterung: Termine allgemein
if(defined $options{3})
{
	$quell_datei =  "D:\\ics\\buero_2010.ics"; 
	$ziel_datei =  "D:\\ics\\buero_2010_termine.ics";
}





open my $ziel_fh, '>', $ziel_datei || die "$ziel_datei konnte nicht geoeffnet werden.\n";
# Header-Datei oeffnen und als erstes vor die Ausgabedatei schreiben.
open my $header_fh , '<', $header_datei || die "$header_datei konnte nicht geoeffnet werden.\n";

while( <$header_fh> ) {
	print $ziel_fh $_;
}
close ($header_fh);


open my $quelle_fh, '<', $quell_datei || die "$quell_datei konnte nicht geoeffnet werden.\n";
while (<$quelle_fh>) {

	SWITCH: {


        	if ( $_ =~ /BEGIN:VEVENT/ ) {
                	##-----------------------------------------
	                ## Neues Event, also initialisieren.
        	        ##-----------------------------------------
                	@AoA = ();
			$match = 0;
			push(@AoA, $_);

	                last SWITCH; }


        	if ( $_ =~ /END:VEVENT/ ) {
                	##-----------------------------------------
                	## Ende des Event, also letzte Zeile
			## speichern und auswerten.
                	##-----------------------------------------
			push(@AoA, $_);
			#print Dumper @AoA;

			## Filtern .....

		

			# 1
			# Filterung: Jahr
			if(defined $options{1}) {
				for my $n ( 0 .. $#AoA ) {
						if ( @{AoA[$n]} =~ /DATE:2010/ ) {
						        $match = 1; 
							print "2010[$match]: @{AoA[$n]}"; }
				}

			}

			# 2
			# Filterung: Urlaub
			if(defined $options{2}) {
				for my $n ( 0 .. $#AoA ) {
						if ( @{AoA[$n]} =~ /Urlaub/ ) {
						        $match = 1;
					       		print "Urlaub[$match]: @{AoA[$n]}\n"; }
				}
			}
				
			# 3
			# Filterung: Termine allgemein
			if(defined $options{3}) {
				$match = 1;
				print "Not Urlaub[$match]: @{AoA[$n]}\n"; 
				for my $n ( 0 .. $#AoA ) {
					if ( @{AoA[$n]} =~ /Urlaub/ ) {
						        $match = 0;
							
					} 
				}
			}




			## ...und Record zurueckschreiben. 
			if ($match == 1) {
				$i++;
				for my $n ( 0 .. $#AoA ) {
					print $ziel_fh "@{AoA[$n]}"; 
					$match = 0; }

			
			}

			#my $taste = <STDIN>;

			last SWITCH; }

	  push(@AoA, $_); } # Ende Switch	
}
close ($quelle_fh);

print $ziel_fh "END:VCALENDAR\n"; # Gesamt Calendar-Endtag schreiben.
close ($ziel_fh);

print "\n";
print "$header_datei\n";
print "$quell_datei\n";
print "$ziel_datei\n";

print "\n$i Datensaetze selektiert.\n";
1;
