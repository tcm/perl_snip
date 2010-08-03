#!/usr/bin/perl -w 

##############################################
# Draft zum Ausfassen ueber GINDEX.
# (jb) 10.06.2010
##############################################

use DBI;

my $version = "0.9";

# Verbindungsparameter MS-SQLSERVER
my $str_dbserver = "testserver";
my $str_user = "user1";
my $str_password = "xxxxxxxxxx";

# Verbindungsparameter Firebird
my $dbhost = "testserver2";
my $str_user2 = "user1";
my $str_password2 = "xxxxxxxxxxx";

my $sql;
my $dbh;
my $sth;
my @row;

my $str_eing_gindex;
my $str_eing_gindex_view;
my $str_eing_menge;
my $str_eing_tnummer;
my $int_pcount;

my $clear = `clear`;

my $str_tnummer;
my $int_lager_id;
my $int_benutzer_id;
my $int_menge;
my $int_abweichung = 2;
my $str_lagerplatz;
my $str_menge;
				 
my $bool_holdon_error;
my $str_statustext_scr;
my $str_ausgabezeile_scr;

### Start-Bildschirm
#####################
print $clear;
print "Version: $version\n";
print "Host: $str_dbserver\n";
sleep (1);


# Die grosse Aussenschleife
while (1) {                      # 1.


# 2. while-Schleife, die solange durchlaufen wird,
# bis wir ein GINDEX mit Artikelnummer haben.
while (1) {                      # 2.

    $int_pcount = 0;
	$str_eing_gindex = "";

	$str_tnummer = "";
	$int_lager_id = 0;
	$int_benutzer_id = 0;
	$int_menge = 0;
	$str_lagerplatz = "";
						
	until ($str_eing_gindex ne "" and $str_eing_gindex =~ /^\d\d/ ) {
		print "\nGI>";
		chop($str_eing_gindex = <STDIN>);
	}
    $str_eing_gindex_view = $str_eing_gindex; # Fuer unten merken.

	if ($str_eing_gindex eq "99") { # Exit fuer das 1. while
		last;
	}


	### I. ARTIKELNUMMER und MENGE
	### ermitteln.
	### MS-SQLSERVER 
	################################
	$dbh = DBI->connect("dbi:Sybase:server=$str_dbserver", $str_user, $str_password, {PrintError => 0, RaiseError => 1});

	### 1. Datenbank wechseln.
	###########################
	$sql = "use PASS";
	# print ("SQL-Kommando fuer SQL-Server:    $sql\n");
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();

	### 2. Stueckzahl und Artikelnummer aus GINDEX ermitteln. 
	##########################################################
	$sql = "exec hole_Daten_aus_GINDEX $str_eing_gindex";
	#print ("SQL-Kommando fuer SQL-Server:    $sql\n");
	$sth = $dbh->prepare($sql);
	$sth->execute();
	

	### Ergebnis ausgeben.
	#######################
	@row = $sth->fetchrow_array;

	if (@row) {        # GINDEX vorhanden?
		#print "#ID: $row[0]\n";
 		#print "#INDEXNUMMER: $row[1]\n";
 		#print "#POS_ID: $row[2]\n";
 		#print "#TYP: $row[3]\n";
 		#print "#KOMNR: $row[4]\n";
 		#print "#ARTIKELNUMMER: $row[5]\n";
 		#print "#MENGE: $row[6]\n";
 		#print "#DATUM: $row[7]\n";
		
		
 		if ( $row[5] ) { # Artikelnummer vorhanden?
			    $str_tnummer = $row[5];
			    $int_pcount++;
			
			
			if ( $row[6] ) { # Menge vorhanden?
			       $int_menge = $row[6];
				   $int_pcount++; }
		    
			last;
		} else {
	    	print "Keine Artikelnummer\nvorhanden.\n";
		}
	
	} else {
		print "Kein GINDEX\nvorhanden.\n";
	} 
	
	$sth->finish();
	#### Verbindung abbauen.
	########################
	$dbh->disconnect(); 


} # 2. while (Innenschleife) 

if ($str_eing_gindex eq "99") { # Exit fuer das 2. while
  last;
}

	### II. LAGERPLATZ ermitteln.
	### Firebird-Server.
	############################################################
	$sql = "SELECT * FROM SP_ERMITTLE_LAGERPLATZ(?)";
	#print "\n\nSQL-Kommando fuer Firebird: $sql\n";

	
	### Verbindung zur Datenbank herstellen.
	#############################################################
	$dbh = DBI->connect("dbi:InterBase:$dbhost:/space/pass/Interbase/Lagerverwaltung.gdb", $str_user2, $str_password2, {PrintError => 0, RaiseError => 1} );


  
	$sth = $dbh->prepare ( $sql );
	$sth->bind_param( 1, $str_tnummer);
	$sth->execute();
	@row = $sth->fetchrow_array; 	 
	#print "Artikelnummer: $row[0]\n";
	#print "Lagerplatz: $row[1]\n"; 
	#print "Datum: $row[2]\n"; 
    if ($row[1]) { # Lagerplatz vorhanden?
	     
	     $str_lagerplatz = $row[1];
		 
		 if  ($str_lagerplatz =~ /^L\d\d-/ ) { # Gueltiger Lagerplatz?
		 	$int_pcount++;
		 } else {
		    print "Ungueltiger Lagerplatz\n";
		 }
		 
	} else {
	  $str_lagerplatz = "(Null)";
	}
	$sth->finish();
   
	################################################
    $dbh->disconnect();

### III. STUECKZAHL buchen.
### Firebird-Server.
#############################################################
$sql = "SELECT * FROM SP_STUECKZAHL_BUCHEN_2( ?, ?, ?, ?, ? )";
#print "\n\nSQL-Kommando fuer Firebird: $sql\n";

$int_lager_id = atoi(substr($str_lagerplatz,1,2));      # Zeichen 2-3 extrahieren
   													    # und in Integer umwandeln.


$int_benutzer_id = 0;

print "\n";
#print "TN> $str_tnummer\n" ;  
#print "LAGER_ID: $int_lager_id\n";
#print "BENUTZER_ID: $int_benutzer_id\n";
#print "MENGE: $int_menge\n";
print "LP:$str_lagerplatz";

# Lagerplatz Detailansicht
#
if ($str_lagerplatz ne "(Null)") {
	print "\nLager: ".substr($str_lagerplatz,1,2);
	print "\nRegal: ".substr($str_lagerplatz,4,2);
	print "\nFach: ".substr($str_lagerplatz,6,2);
	print "\nEbene: ".substr($str_lagerplatz,8,2);
	print "\nKiste: ".substr($str_lagerplatz,10,2);
	#print "\nFach: ".substr($str_lagerplatz,12,2);
}
print "\nTN:$str_tnummer" ;  

# Teilenummer pruefen.
# Muss richtig eingescannnt werden,
# sonst geht's nicht weiter.
###################################
$str_eing_tnummer = "";

until ($str_eing_tnummer eq $str_tnummer) {      # Entspricht die eingelesene Teilenummer der eingescannten?
	print "\nTN>";                               
	chop($str_eing_tnummer = <STDIN>);

	if ($str_eing_tnummer ne $str_tnummer) {
		print "Falsche Teilenummer\neingescannt.\n";
	}

	if ($str_eing_tnummer eq "99") {             # Um doch aus der Schleife rauszukommen.
	    $str_tnummer = "(Null)"; 
	 	last;
	}
}

if ( $int_pcount < 3 ) {
	print "Nicht gebucht.\nEs fehlt ein Parameterwert.\nint_pcount = $int_pcount\n";

} elsif ($str_eing_gindex eq "99") {
    last;

} else {
			 

    # Evtl. die Menge korrigieren.
    ################################
    $str_eing_menge = "";
    print "\nSOLL-ST:$int_menge";               # Soll-Menge anzeigen.
    until ($str_eing_menge =~ /^\d+$/  and $str_eing_menge <= $int_menge + $int_abweichung) { 
          print "\nST>";
	      chop($str_eing_menge = <STDIN>);
    }
    $int_menge = $str_eing_menge;
	
	# Verbindung zur Datenbank herstellen.
	#############################################################
	$dbh = DBI->connect("dbi:InterBase:$dbhost:/space/pass/Interbase/Lagerverwaltung.gdb", $str_user2, $str_password2, {PrintError => 0, RaiseError => 1} );
		

	my $sth = $dbh->prepare ( $sql )
		or die "\nKann SQL-Statement\nnicht vorbereiten.\n";
 
	$sth->bind_param( 1, $str_tnummer);
	$sth->bind_param( 2, $int_lager_id);
	$sth->bind_param( 3, $int_benutzer_id);
	$sth->bind_param( 4, $int_menge);
	$sth->bind_param( 5, $str_lagerplatz);
	$sth->execute()
		or die "\nKann SQL-Statement\nnicht ausfuehren.\n";
 
	# Rueckgabewert auslesen, und entsprechend
	# den Statustext zuweisen.
	##################################################
	@row =$sth->fetchrow_array;  # Geht ausnahmsweise, da wir immer nur 
    	                          # einen Datensatz erhalten werden!
 
 
	# Fehlerabfrage bei schwerwiegenden Fehlern
	# in der Stored Procedure selbst.
	###################################################
	if ($sth->err() ) {
		$int_rueckgabewert = 10;        # Bei einem DBI-Fehler auf Rueckgabewert 10 setzen.
	} else{
		$int_rueckgabewert = $row[0];   # Sonst unseren Rueckgabewert aus der Prozedur nehmen.
	}
 
	$sth->finish();
 
	# Verbindung zur Datenbank beenden.
	################################################
	$dbh->disconnect()
		or warn "Der Verbindungsabbau\nist fehlgeschlagen:\n", $dbh->errstr(), "\n";

	 # Zuweisen der Fehlerausgabetexte.
	 # und des 'Hold on Error'-Flags.
	 #########################################################
	 if ($int_rueckgabewert == 0) {
		 $bool_holdon_error = 0;
	     $str_statustext_scr = "0: gebucht\n";
	 
	} elsif ($int_rueckgabewert == 1) {
		$bool_holdon_error = 1;
		$str_statustext_scr = "1: nicht gebucht\nFalsche Teilenummer\n";
		 
	} elsif ($int_rueckgabewert == 2) {
		$bool_holdon_error = 1;
	    $str_statustext_scr = "2: nicht gebucht\nUnterbuchung\n";
	 
	} elsif ($int_rueckgabewert == 10) {
	    $bool_holdon_error = 1;
		$str_statustext_scr = "10: nicht gebucht\nSchwerer Fehler\n";
	}
	 
	# Ausgabezeile zusammensetzen.
	###############################################
	# print strftime "%d/%m/%Y\n", localtime;
	 
	# Ausgabezeile fuer den Bildschirm
	$str_menge = substr("000".$int_menge, -3);
	$str_ausgabezeile_scr = "$str_tnummer $int_lager_id $str_menge A\n$str_statustext_scr";
	print ("\n\n$str_ausgabezeile_scr");

	if ($bool_holdon_error == 1 ) {     # Bei Fehler auf Tastendruck
		$bool_holdon_error = 0;         # warten.
		print "\nTaste druecken...\n";
		chop($str_dummy = <STDIN>);
		
	}
	 
	 sleep(3);
	 print $clear;
	 print $clear;
	 print "\nTN:$str_tnummer";	 
	 print "\nGI:$str_eing_gindex_view";	 
																														 
	
} # else-Zweig																																																					 


} # 1. while (Aussenschleife)


  
# Funktionen
################################################
   
   
###  String in Integer umwandeln.
sub atoi {
	my $t = 0;
	      
	foreach my $d (split(//, shift())) {
		$t = $t * 10 + $d;
	}  
	return $t;
}
														  

exit 0;
