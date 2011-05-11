#!/usr/bin/perl -w 

##############################################
# Draft zum Ausfassen ueber GINDEX.
# (jb) 17.08.2010
#      27.10.2010
# Version ohne strikte Plausibilitaetspruefung
##############################################

use strict;
use DBI;

my $version = "0.99";

# Verbindungsparameter MS-SQLSERVER
my $str_dbserver = "testserver1";
my $str_user = "user1";
my $str_password = "xxxxxxxxxxx";

# Verbindungsparameter Firebird
my $dbhost = "testserver2";
my $str_user2 = "user2";
my $str_password2 = "xxxxxxxxx";

my $sql;
my $dbh;
my $sth;
my @row;

my $str_eing_gindex;
my $str_eing_gindex_view;
my $str_eing_menge;
my $str_eing_tnummer;
my $str_eing_lagerplatz;
my $int_pcount;
my $str_dummy_lagerplatz = "L00-0000000000";

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

my $int_rueckgabewert;
my $str_dummy;

# Fehlerkonstanten.
my $C_MENGE_NULL = 8;
my $C_ARTIKELNUMMER_NULL = 4;
my $C_LAGERPLATZ_FORMAT_FALSCH = 2;
my $C_LAGERPLATZ_NULL = 1;


### Start-Bildschirm
#####################
print $clear;
print "Version: $version\n";
print "Host: $str_dbserver\n";
print "Host2: $dbhost\n\n";
sleep (1);


# Die grosse Aussenschleife
while (1) {                      # 1.

#print $clear;
# 2. while-Schleife, die solange durchlaufen wird,
# bis wir ein GINDEX mit Artikelnummer haben.
while (1) { # 2.                     

    $int_pcount = 0;
	$str_eing_gindex = "";

	$str_tnummer = "";
	$int_lager_id = 0;
	$int_benutzer_id = 0;
	$int_menge = 0;
	$str_lagerplatz = "";
	
	until ($str_eing_gindex ne "" and $str_eing_gindex =~ /^\d\d/ ) {
	    print "\nGINDEX scannen:\n";
		print "\nGI>";
		chop($str_eing_gindex = <STDIN>);
	}
    $str_eing_gindex_view = $str_eing_gindex; # Fuer unten merken.
    if ($str_eing_gindex eq "99") {           # Harter Abbruch.
	   exit 0;
	}

	### I. ARTIKELNUMMER und MENGE
	### ermitteln.
	### MS-SQLSERVER 
	################################
	$dbh = DBI->connect("dbi:Sybase:server=$str_dbserver", $str_user, $str_password, {PrintError => 0, RaiseError => 1});

	### I.1 Datenbank wechseln.
	###########################
	$sql = "use PASS";
	# print ("SQL-Kommando fuer SQL-Server:    $sql\n");
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();

	### I.2 Stueckzahl und Artikelnummer aus GINDEX ermitteln. 
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
		
		
		# I.3 Artikelnummer und Menge vorhanden?
		##################################################
		if ( $row[6] ) {
			$int_menge = $row[6];
		} else {
		    $int_menge = 0;
		    $int_pcount += 8;
			
		}
		
 		if ( $row[5] ) { 
			    $str_tnummer = substr($row[5],0,9);
		} else {
			    $str_tnummer = "(Nicht gefunden)";
		        $int_pcount += 4;	
				print $clear;
		    	print "Keine Artikelnummer\nvorhanden.\n";
		}
	
	} else {
		print $clear;
		print "Kein GINDEX\nvorhanden.\n";
	} 
	
	$sth->finish();
	#### Verbindung abbauen.
	########################
	$dbh->disconnect(); 

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
	

	# II.1 Gueltiger Lagerplatz?
	#############################################
	if ($row[1]) { 
	 
	$str_lagerplatz = $row[1];
	if  ($str_lagerplatz =~ /^L\d\d-/ ) { 
	  #
	} else {
		print "Ungueltiger Lagerplatz\n";
		$str_lagerplatz = $str_dummy_lagerplatz;
		$int_pcount += 2;
	}
	 
	} else {
		$str_lagerplatz = $str_dummy_lagerplatz;
		$int_pcount += 1;
	}
	$sth->finish();
	
	################################################
	$dbh->disconnect();


    # Pruefen die Parameter richtig sind.
	# Wir sind mal nicht so streng.
	# Nur die Menge ist wichtig!
	if ( $int_pcount & $C_MENGE_NULL ) {
	 	printf ("%010b\n",$int_pcount);
	    print "Menge: $int_menge\n";
		
	} else {
	    last;
	}

} # 2. while 


### III. STUECKZAHL buchen.
### Firebird-Server.
#############################################################
$sql = "SELECT * FROM SP_STUECKZAHL_BUCHEN_2( ?, ?, ?, ?, ? )";
#print "\n\nSQL-Kommando fuer Firebird: $sql\n";

$int_lager_id = atoi(substr($str_lagerplatz,1,2));      # Zeichen 2-3 extrahieren

$int_benutzer_id = 9;


# Teilenummer pruefen.
# Muss richtig eingescannnt werden,
# sonst geht's nicht weiter.
###################################
$str_eing_tnummer = "";

until ($str_eing_tnummer eq $str_tnummer) {      # Entspricht die eingelesene Teilenummer der eingescannten?
     print $clear;
     #print "TN> $str_tnummer\n" ;  
	 #print "LAGER_ID: $int_lager_id\n";
	 #print "BENUTZER_ID: $int_benutzer_id\n";
	 #print "MENGE: $int_menge\n";
	 #print "LP:$str_lagerplatz";
	 
	 # Lagerplatz Detailansicht
	 #
	 print "\nLager: ".substr($str_lagerplatz,1,2);
	 print "\nRegal: ".substr($str_lagerplatz,4,2);
	 print "\nFach: ".substr($str_lagerplatz,6,2);
	 print "\nEbene: ".substr($str_lagerplatz,8,2);
	 print "\nKiste: ".substr($str_lagerplatz,10,2);
	 print "\nFach: ".substr($str_lagerplatz,12,2);
	 
	print "\nTN:$str_tnummer" ;
	print "\n";

	print "\nTeilenummer scannen:";                               
	print "\nTN>";                               
	chop($str_eing_tnummer = <STDIN>);
   
   if ($int_pcount & $C_ARTIKELNUMMER_NULL) {            # 1. Um aus dieser Schleife rauszukommen, 
   		last;                                            # wenn wir keine Artikelnummer haben.
	}
		   

   if ($str_eing_tnummer eq "99") {                     # 2. Um  aus dieser Schleife rauszukommen,
	   last;                                            # wenn wir abbrechen wollen.  
	}

	if ($str_eing_tnummer ne $str_tnummer) {
		print "Falsche Teilenummer\ngescannt.\n";
		sleep(2);
	}

}
																	   
$str_tnummer = $str_eing_tnummer;

    # Die Menge
	# und den Lagerplatz abfragen.
    ################################
	if ($str_eing_tnummer ne "99") {                     # Menge und Lagerplatz nur abfragen, wenn wir nicht abbrechen wollen. 
        
		if ($int_pcount & $C_LAGERPLATZ_NULL ) {         # Lagerplatz nur abfragen, wenn wir keinen Lagerplatz ermitteln konnten.
		
        	# Lagerplatz abfragen.
			#
			$str_eing_lagerplatz = "";
			until ($str_eing_lagerplatz ne "" and $str_eing_lagerplatz =~ /^L\d\d-/ ) {
				print ("LP>");
				chop($str_eing_lagerplatz = <STDIN>);
        	}
	        $str_lagerplatz = $str_eing_lagerplatz;
		}
	
        # Menge abfragen.
		#
	    $str_eing_menge = "";
    	print "\nSOLL-STUECK: $int_menge";               # Soll-Menge anzeigen.
    	until ($str_eing_menge =~ /^\d+$/  and $str_eing_menge <= $int_menge + $int_abweichung) { 
	
	    	print "\nStueckzahl eingeben:";
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
	 
	 	sleep(2);
	 	print $clear;
	 	print "\nTN:$str_tnummer";	 
	 	print "\nGI:$str_eing_gindex_view\n";	 
	} 

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
