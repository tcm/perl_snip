#!/usr/bin/perl -w


################################################
# Direkte Teileeinbuchung in die Lagerdatenbank. 
# 
# (jb) 10.08.2002
# geaendert: 21.07.2008
# geaendert: 20.08.2008
# geaendert: 14.04.2010
################################################

use DBI;                # Das DBI-Modul laden
use POSIX qw(strftime);

########################
# Variablen-Deklaration
########################

my $version = "1.0";

### Werte die ueber ein Prompt eingegeben werden. 
my $str_eing_teilenummer;
my $str_eing_lagerplatz;
my $str_eing_stueckzahl;
my $str_eing_zuab;

###  Werte nur fuer die Bildschirmanzeige
my $str_stueckzahl;         # Stueckzahl im Format 00x
my $str_zuab;               # A, Z oder FT

### Verschiedenes 
my $int_rueckgabewert;      # DBI-Rueckgabewert

my $str_ausgabezeile_scr;   # Die Statusmeldung auf dem Bildschirm
my $str_statustext_scr;     # Rueckmeldung der Stored Procedure

my $str_dummy;
my $bool_holdon_error;
my $clear = `clear`;

### Datenbankverbindungsparameter.
my $dbhost= "vm-suse10-3-2";
#my $dbhost= "lagervw";
my $str_dsn = "dbi:InterBase:$dbhost:/space/pass/Interbase/Lagerverwaltung.gdb";
my $str_user = "user1";
my $str_password = "xxxxxxxxx";

### Uebergabeparameter fuer die Stored Procedure. 
my $str_tnummer;
my $int_lager_id;
my $int_benutzer_id;
my $int_menge;
my $str_lplatz;

### SQL-Anweisungen festlegen.
my $sql_1 = "SELECT * FROM SP_STUECKZAHL_BUCHEN_2( ?, ?, ?, ?, ? )";
my $sql_2 = "SELECT * FROM SP_FEHLTEILE_AUFNEHMEN( ?, ?,  ?, ? )";
	
############################
# Startbildschirm
############################
print $clear;
print "Version: $version\n";
print "Host: $dbhost\n";
sleep(3);

while (1) {                 # Die grosse Aussenschleife.

  ########################################
  # Teilenummer abfragen.
  #
  # Minimale Laenge = 1
  # Maximale Laenge = 20 
  # Sonst alle Zeichen erlaubt.
  #
  # 99 = Abruch
  ########################################
  $str_eing_teilenummer = "";
  until ($str_eing_teilenummer ne "") {
    print ("\nTN>");
    chop($str_eing_teilenummer = <STDIN>);
  }	
  if ($str_eing_teilenummer eq "99") {    # Schleife radikal verlassen.
     last;
  }
 
  ########################################
  # Lagerplatz abfragen.
  #
  # LP = L01-12345678901 
  # 99 = Abruch
  ########################################
  $str_eing_lagerplatz = "";
  until ($str_eing_lagerplatz ne "" and $str_eing_lagerplatz =~ /^L\d\d-/ ) {
    print ("LP>");
    chop($str_eing_lagerplatz = <STDIN>);
	
  }	
  if ($str_eing_lagerplatz eq "99") {    # Schleife radikal verlassen.
     last;
  }
 
  #############################    
  # Stueckzahl abfragen.
  # 
  # Nur ganze Zahlen erlaubt.
  # 0 = Abruch 
  #############################
  $str_eing_stueckzahl = "";
  until ($str_eing_stueckzahl =~ /^\d+$/  and $str_eing_stueckzahl <= 999) { # Pruefe auf ganze Zahlen.
   print ("ST>");                                                            # Ausserdem darf die Zahl
   chop($str_eing_stueckzahl = <STDIN>);                                     # 999 nicht ueberschreiten.
  }  
  if ($str_eing_stueckzahl eq "0") {         # Schleife radikal verlassen.
     last;
  }
  $str_stueckzahl = substr("000".$str_eing_stueckzahl,-3); # Formatierzuweisung fuer 
                                                           # Die Stueckzahlzuweisung fuer den
														   # Datenbankparameter erfolgt weiter 
														   # unten, weil wir dazu noch wissen
														   # muessen ob Zugang oder Abgang.
  
  #################################
  # Zugang oder Abgang abfragen.
  #
  # Nur 1, 2 oder 3 erlaubt.
  # Ok, 4 ist dann doch Abbruch.
  #################################
  $str_eing_zuab = "";
  until ($str_eing_zuab eq "1" or $str_eing_zuab eq "2" or $str_eing_zuab eq "3" or $str_eing_zuab eq "4") {
    print ("1=Zu 2=Ab 3=FT 4=Q\n");
    print (">");
    chop($str_eing_zuab = <STDIN>);
   }
  
  if ($str_eing_zuab eq "1") {             # Formatierzuweisung fuer Ab- und Zugang.
   $str_zuab = "Z";                        # und auch fuer die Datenbankstueckzahl.
   $int_menge = $str_eing_stueckzahl;      # Bei Zugang Wert so lassen.
   
  } elsif ($str_eing_zuab eq "2" ) {
   $str_zuab = "A";
   $int_menge = (-1) * $str_eing_stueckzahl;      # Bei Abgang muss ein Minus davor.
   
  } elsif ($str_eing_zuab eq "3" ) {
   $str_zuab = "FT";
   $int_menge = $str_eing_stueckzahl;             # Fehltteil: Wert so lassen.
   
  } elsif ($str_eing_zuab eq  "4" ) {             # Schleife radikal verlassen.
   last;
  }
  
  #################################################
  # Buchung in der Datenbank ausfuehren.
  #################################################

  ### Parameter aus der Eingabezeile zuweisen
  $str_tnummer = substr($str_eing_teilenummer,0,20);      # Nur die ersten 20 Zeichen.
  
  $int_lager_id = atoi(substr($str_eing_lagerplatz,1,2)); # Zeichen 2-3 extrahieren
                                                          # und in Integer umwandeln.
  $int_benutzer_id = 0;
  
  # $int_menge                                            # wird oben in Abhaengigkeit von $str_eing_zuab gesetzt.  
  
  $str_lplatz = substr($str_eing_lagerplatz,0,14);        # Nur die ersten 14 Zeichen.
 
  # Zum Debuggen
  #print "$str_tnummer ";
  #print "$int_lager_id ";
  #print "$int_benutzer_id ";
  #print "$int_menge\n";  
  #exit 1; 
 
 
  #############################################################
  # Verbindung zur Datenbank herstellen.
  #############################################################
  my $dbh = DBI->connect($str_dsn, $str_user, $str_password )
    or die "\nDie Verbindung zur Datenbank\nkonnte nicht hergestellt werden.\n";


  #############################################################
  # SQL-Anweisungen vorbereiten und Parameter uebergeben.
  # Fallunterscheidung: Bestandsbuchung oder Fehlteil buchen.
  #############################################################
  if ( $str_eing_zuab eq "1" or $str_eing_zuab eq "2" ) {
   $sqlstring = $sql_1;
  } elsif ( $str_eing_zuab eq "3" ) {
   $sqlstring = $sql_2;
  }
  
  my $sth = $dbh->prepare ( $sqlstring )        
    or die "\nKann SQL-Statement\nnicht vorbereiten.\n";
	
   $sth->bind_param( 1, $str_tnummer);
   $sth->bind_param( 2, $int_lager_id);
   $sth->bind_param( 3, $int_benutzer_id);
   $sth->bind_param( 4, $int_menge);
   $sth->bind_param( 5, $str_lplatz);
   $sth->execute()
     or die "\nKann SQL-Statement\nnicht ausfuehren.\n";
	 
   ##################################################
   # Rueckgabewert auslesen, und entsprechend
   # den Statustext zuweisen.
   ##################################################
   @row =$sth->fetchrow_array;  # Geht ausnahmsweise, da wir immer nur 
                                # einen Datensatz erhalten werden!
  

   ###################################################
   # Fehlerabfrage bei schwerwiegenden Fehlern
   # in der Stored Procedure selbst.
   ###################################################
   if ($sth->err() ) {
	 $int_rueckgabewert = 10;        # Bei einem DBI-Fehler auf Rueckgabewert 10 setzen.
	} else{
	 $int_rueckgabewert = $row[0];   # Sonst unseren Rueckgabewert aus der Prozedur nehmen.
   }

   $sth->finish();
   
   ################################################
   # Verbindung zur Datenbank beenden.
   ################################################
   $dbh->disconnect()
    or warn "Der Verbindungsabbau\nist fehlgeschlagen:\n", $dbh->errstr(), "\n";
 	
  #########################################################
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

  ##############################################
  # Ausgabezeile zusammensetzen.
  ###############################################
  # print strftime "%d/%m/%Y\n", localtime;
  
  # Ausgabezeile fuer den Bildschirm
  $str_ausgabezeile_scr = "$str_tnummer $int_lager_id $str_stueckzahl $str_zuab\n$str_statustext_scr"; 
  
  print ("\n\n$str_ausgabezeile_scr");

  if ($bool_holdon_error == 1 ) {   # Bei Fehler auf Tastendruck
    $bool_holdon_error = 0;         # warten.
	print "\nTaste druecken...\n";
	chop($str_dummy = <STDIN>);
  }
  
  sleep(3);
  print $clear;
}

exit 0;

################################################
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
