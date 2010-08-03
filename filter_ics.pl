#!/usr/bin/perl

use Data::Dumper;
use Getopt::Std;


my @AoA;
my $n;
my $match;
my $i = 0;
my %options; # assoziatives array fuer die uebergebenen Optionen
my $quell_datei = "<Quelldatei>";
my $ziel_datei = "<Zieldatei>";
my $header_datei =  "<D:\\project_ics\\header.txt";

getopts('123',\%options);

# 1
# Filterung: Jahr
if(defined $options{1})
{
	$quell_datei =  "<D:\\project_ics\\buero.ics"; 
	$ziel_datei =  ">D:\\project_ics\\buero_2009.ics";
}

# 2
# Filterung: Urlaub
if(defined $options{2})
{
	$quell_datei =  "<D:\\project_ics\\buero_2009.ics"; 
	$ziel_datei =  ">D:\\project_ics\\buero_2009_urlaub.ics";
}

# 3
# Filterung: Termine allgemein
if(defined $options{3})
{
	$quell_datei =  "<D:\\project_ics\\buero_2009.ics"; 
	$ziel_datei =  ">D:\\project_ics\\buero_2009_termine.ics";
}




open (QUELLE, $quell_datei) || die "$quell_datei konnte nicht geoeffnet werden.\n";
open (ZIEL, $ziel_datei) || die "$ziel_datei konnte nicht geoeffnet werden.\n";

# Header-Datei öffnen und als erstes vor die Ausgabedatei schreiben.
open (HEADER, $header_datei) || die "$header_datei konnte nicht geoeffnet werden.\n";
while( <HEADER> ) {
	print ZIEL $_;
}
close (HEADER);


while (<QUELLE>) {

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
				for $n ( 0 .. $#AoA ) {
						if ( @{AoA[$n]} =~ /DATE:2009/ ) {
						        $match = 1; 
							print "2009[$match]: @{AoA[$n]}"; }
				}

			}

			# 2
			# Filterung: Urlaub
			if(defined $options{2}) {
				for $n ( 0 .. $#AoA ) {
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
				for $n ( 0 .. $#AoA ) {
					if ( @{AoA[$n]} =~ /Urlaub/ ) {
						        $match = 0;
							
					} 
				}
			}




			## ...und Record zurueckschreiben. 
			if ($match == 1) {
				$i++;
				for $n ( 0 .. $#AoA ) {
					print ZIEL "@{AoA[$n]}"; 
					$match = 0; }

			
			}

			#my $taste = <STDIN>;

			last SWITCH; }

	  push(@AoA, $_); } # Ende Switch	
}
print ZIEL "END:VCALENDAR\n"; # Gesamt Calendar-Endtag schreiben.

print "\n";
print "$header_datei\n";
print "$quell_datei\n";
print "$ziel_datei\n";

print "\n$i Datensaetze selektiert.\n";
close (QUELLE);
close (ZIEL);
