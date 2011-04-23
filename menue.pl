#!/usr/bin/perl

use Data::Dumper;

my $taste1;
my $taste2;
my $ausg;
my $i;
my $j;
my @AoA = ();
my @felder;
my @temp;


open (IN, "/etc/printcap") || die "Eingabedatei kann nicht geoeffnet werden.\n";

while (<IN>) {
		
	# print $_;
	if (/^rlp/) {                       # Zeile beginnt mit rlp?
	
		@felder = split(/:/,$_);    # Nach Trennzeichen : splitten.
		push(@temp,$felder[2]);	    # Feld mit Drucker-Namen in Array.
		push(@temp,$felder[0]);     # Feld mit Queue in Array.
		$AoA[$i] = [@temp];         # Speichern.
		@temp = ();                 # Temp-array wieder leeren.
		$i++;
	}
}


while (1) {

	# print Dumper @AoA;
	
	# Menue1 ausgeben.
	# 
	for $i (0 .. $#AoA) {
	  print "$i.   ";
	  for $j (0 .. $#{$AoA[$i]}) {

		print "$AoA[$i][$j]      ";
	  }
	  print "\n";
	}
	print "\nIhre Wahl:";
	$taste1=<STDIN>;


	# Menue 2 ausgeben.
	#
	print "1. Warteschlange $AoA[$taste1][0] anzeigen.\n";
	print "2. Warteschlange $AoA[$taste1][0] loeschen.\n\n";
	print "3. LPD neu starten.\n";
	print "4. SAMBA neu starten.\n";

	print "\nIhre Wahl:";
	$taste2=<STDIN>;

	
	# 
	# ##################
	if ($taste2 == 1) {
	  $ausg = `lpq -P $AoA[$taste1][1]`;
	  print "$ausg\n";
	  $taste=<STDIN>;
	}
	
	if ($taste2 == 2) {
	 
	  $ausg = "rm /var/spool/lpd/$AoA[$taste1][1]/*";
	  print "$ausg\n";
	  system ($ausg);
	  $ausg = "rm /var/tmp$AoA[$taste1][1]/*";
	  print "$ausg\n";
	  system ($ausg);
	  $taste=<STDIN>;
	}
	if ($taste2 == 3) {
	  $ausg = `/etc/init.d/lpd restart`;
	  print "$ausg\n";
	  $taste=<STDIN>;
	}
	if ($taste2 == 4) {
	  $ausg = `/etc/init.d/smb restart`;
	  print "$ausg\n";
	  $ausg = `/etc/init.d/nmb restart`;
	  print "$ausg\n";
	  $taste=<STDIN>;
	}
}
