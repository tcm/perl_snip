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
my $ofilename="genreset.sh";

open (IN, "/etc/printcap") || die "Eingabedatei kann nicht geoeffnet werden.\n";
open (OUT, ">$ofilename") || die "Ausgabedatei kann nicht geoeffnet werden.\n";


print OUT "#!/bin/bash\n";
print OUT "\n";
while (<IN>) {
		
	# print $_;
	if (/^rlp/) {                       # Zeile beginnt mit rlp?
	
		@felder = split(/:/,$_);    # Nach Trennzeichen : splitten.
		#push(@temp,$felder[2]);    # Feld mit Drucker-Namen in Array.
		push(@temp,$felder[0]);     # Feld mit Queue in Array.
		$AoA[$i] = [@temp];         # Speichern.
		@temp = ();                 # Temp-array wieder leeren.
		$i++;
	}
}

	# print Dumper @AoA;
	
	for $i (0 .. $#AoA) {
	  for $j (0 .. $#{$AoA[$i]}) {

		#print OUT "lprm -P $AoA[$i][$j]\n";
		print OUT "rm /var/spool/lpd/$AoA[$i][$j]/*\n";
		print OUT "rm /var/tmp$AoA[$i][$j]/*\n";
		
	  }
	  print OUT "\n";
	}
print OUT "\n";
print OUT "/etc/init.d/lpd restart\n";
#print OUT "/etc/init.d/smb restart\n";
close (IN);
close(OUT);

unless (chmod(0777,$ofilename)) {
	print "Dateirechte konnten nicht geaendert werden.\n";
}

while (1) {
	print "Taste drücken\n";
	$taste1=<STDIN>;

	print "./$ofilename\n";
	system("./$ofilename");
}

