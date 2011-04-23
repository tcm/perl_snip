#!/usr/bin/perl -w

use strict;
use DBI;
use Getopt::Std;
use Data::Dumper;
use XML::Parser;
use XML::XPath;



			 
##########################################
# XML in SQL-Server Datenbank schreiben.
# (c) jb Jan/Feb/Juli/August 2006
# (c) jb Jan/Feb/Mai 2007
# V 1.1
##########################################
my $C_POS_ZEICHNR = 10;        # Spaltenposition der Zeichnungsnummer.

my $str_filename = "dummy"; # Filename des Files das zerlegt werden soll.
my $xml_filename1 = "dummy"; # Filename fuer XML-File (Stueckliste)

my $int_anzahl = 0; # Zeilen im Array
my $int_laenge = 0; # Spalten im Array
my $aref1;          # Referenz des Rueckgabewertes.
my $aref2;          # Temporaere Variable.

my $int_i = 0; # Die Zaehler
my $int_j = 0;

my $str_werkzeug_id = "dummy"; # Werkzeug_ID


### DB-Variablen
my $str_dbi = "dbi:Sybase:server=server70";
my $str_user = 'user';
my $str_password = 'passwort';
my $str_sql = "dummy"; # SQL-String
my $sth;

my $str_eingabe = "dummy";
my $str_pro_nr = "600999";
my %options=();

##################################
#
# Behandlung der Optionen
# in der Kommandozeile.
#
#################################
getopts("p:t",\%options);

if ( defined $options{p} ) {
  $str_pro_nr = $options{p};
}

if ( defined $options{t} ) {
  $str_dbi = "dbi:Sybase:server=testserver70";
}

	###############################################
	# Zur Datenbank verbinden.
	###############################################
	my $dbh = DBI->connect($str_dbi, $str_user, $str_password, {PrintError => 0})
		or die "Unable for connect to server $DBI::errstr";
					
    #################################################
    # Filenamen fuer das Projekt bestimmen.
    #################################################
	$str_filename = stueckliste_bestimmen($str_pro_nr); 
	
	# Fehlertext in Stueckliste schreiben.
    if ( $str_filename =~ /Error/ ) {

         chop($str_filename);
	     $str_sql = "exec neuer_Datensatz_STUECKLISTE_FEHLER \'".$str_pro_nr.".err"."\', \'\', \'1\', \'".$str_filename."\'";
		 $sth = $dbh->prepare($str_sql)
		  	or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
		 $sth->execute()
		  	or die "Can't execute SQL Statement: ",$sth->errstr(), "\n"; # SQL-Anweisung ausfuehren.
		 $sth->finish();
		 
		exit 1;
	}
	# print "$str_filename\n";


        ###################################################
	# XML-Files aus der .bom-Datei erzeugen.
	#
	###################################################
	($xml_filename1) = xml_files_erzeugen($str_filename, $str_pro_nr);


     # Fehlertext in Stueckliste schreiben.
	 if ( $xml_filename1 =~ /Error/ ) {
	   
	   chop($xml_filename1);
	   $str_sql = "exec neuer_Datensatz_STUECKLISTE_FEHLER \'".$str_pro_nr.".err"."\', \'\', \'1\', \'".$xml_filename1."\'";
	   $sth = $dbh->prepare($str_sql)
	  	   or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
	    $sth->execute()
	  	    or die "Can't execute SQL Statement: ",$sth->errstr(), "\n"; # SQL-Anweisung ausfuehren.
	  	$sth->finish();
									 
	     exit 1;
	  }
			   

	###################################################
	# Unterprogramm fuer  das Einlesen der Stueckliste
	# aufrufen. Rueckgabewert ist eine Referenz auf das
	# Array und die Werkzeug_ID.
	###################################################
	($aref1, $str_werkzeug_id, $str_pro_nr) = stueckliste_einlesen($xml_filename1);
	
	#############################
        # Debug-File öffnen
	#############################
	open (OUT, ">./csv_database_sql.log") or
		die "csv_database: Die Datei csv_database_sql.log konnte nicht geöffnet werden.\n";

	################################################
	# I. Schritt
	# Datensatz fuer bestimmes Projekt löschen.
	################################################
	$str_sql = "exec loesche_Projekt_STUECKLISTE \'".$str_pro_nr."\'";
	print OUT "SQL:    $str_sql\n\n";                                 # String anzeigen.
	$sth = $dbh->prepare($str_sql)
		or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
	$sth->execute()
		or die "Can't execute SQL Statement: ",$sth->errstr(), "\n"; # SQL-Anweisung ausfuehren.
	$sth->finish();
						
	

	###############################################
	# II. Schritt
	# Datensaetze der Stueckliste einfuegen.
	################################################
	# SQL-Beispielstring: 
	# $str_sql = "exec neuer_Datensatz_STUECKLISTE \'1111111\', '\12342344', \'nnn'\, \'1\',  \'2\',  \'3\',  \'4\',  \'5\',  \'6\',  \'7\',  \'8\'";

	#########################################
	# Grosse Aussenschleife fuer die Zeilen.
	# Zeile fuer INSERT zusammensetzen.
	#########################################
	$int_anzahl = $#$aref1; # Anzahl der Zeilen auslesen.
	$aref2 = $aref1->[0];
    $int_laenge = @$aref2 - 1; # Anzahl der Spalten auslesen.
	
	print OUT "Z: (0..$int_anzahl) S: (0..$int_laenge)\n";
	print OUT "---------------------------------------------------------------------------\n";
	for ( $int_i = 0 ; $int_i <= $int_anzahl  ; $int_i++) {

		$str_sql = "exec neuer_Datensatz_STUECKLISTE \'".$str_pro_nr."\'"; # Anfang des SQL-Strings
		$str_sql = $str_sql." ,\'".$str_werkzeug_id."\'";
		$str_sql = $str_sql." ,\'".($int_i + 1)."\'";
		

	    # Innenschleife fuer die Fn-Felder.	
    	for ( $int_j = 0 ; $int_j <= $int_laenge; $int_j++ ) {
			$str_sql = $str_sql." ,\'".$aref1->[$int_i][$int_j]."\'";# variable Einzelfelder anfuegen
	    }
		
    	print OUT "SQL:    $str_sql\n";                                 # String anzeigen.
		$sth = $dbh->prepare($str_sql)
    		or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n"; 
		$sth->execute()
			or die "Can't execute SQL Statement: ",$sth->errstr(), "\n"; # SQL-Anweisung ausfuehren.
		$sth->finish();
	}					

													   

	###################################################
	# Verbindung abbauen.
	###################################################
	$dbh->disconnect()
		or warn "Disconnect failed : $DBI::errstr\n";

	
exit 0;

###############################################
#
#
# Unterprogramm: Um aus der .bom-Stuecklisten-
# Datei ein konformes XML-File erzeugen.
#
#
################################################
sub xml_files_erzeugen {

my $p;
my $str_verz = "./xml";
my $output1_file = "$str_verz/$_[1]_sl.xml";
my $str_err_msg;
my $int_flag;


#####################################################
# Wenn kein xml-Unterverzeichnis  existiert,
# dann eines anlegen.
######################################################
if ( -e $str_verz ) {
  # schoen!
} else {
  mkdir ($str_verz, 0775) or
    die "E1 xml_files_erzeugen: Verzeichnis $str_verz kann nicht angelegt werden.\n"; 
}
 
#############################
# Eingabefile oeffnen.
#############################
open (IN, $_[0]) or
	die "E2 xml_files_erzeugen: Die Datei $_[0] konnte nicht geöffnet werden.\n";

#############################
# Die Ausgabe-Files oeffnen
#############################
open (OUT, ">$output1_file") or
	die "E3 xml_files_erzeugen: Die Datei $output1_file konnte nicht geöffnet werden.\n";

$int_flag = 0;
while (<IN>) {
	# print $_;
	
	###############
	# Suchmuster 1
	###############
    if ( /Fertigungsbaugruppe/ ) {         
		$int_flag = 1;   
	}
	
	if ($int_flag == 0) {
		print OUT $_;	
	}
	
}

close(IN);
close(OUT);

#########################################
# Ergebnis aus XML-Konformitaet pruefen.
#########################################
$p = XML::Parser->new(ErrorContext=>2);


eval { $p->parsefile($output1_file); }; 
if( $@ ) {
    $@ =~ s/at \/.*?$//s; # Zeilennummer des Moduls entfernen.
	$str_err_msg = "Error: xml_files_erzeugen: $output1_file -->}\n$@\n";
	print $str_err_msg;
	return ($str_err_msg, "Error");
}


return($output1_file);

}

###############################################
#
#
# Unterprogramm: Stueckliste einlesen.
# Liest die Stueckliste aus XML-File1
#
#
################################################
sub stueckliste_einlesen{
my @AoA = ();
my @temp = ();
my $f;
my $int_i = 0;
my $str_werkzeug_id = "dummy";
my $str_pro_nr = "dummy";
my $str_temp;
my $filter_flag = 0;

##################################################
# Stueckliste in Array einlesen auf XML-File1
##################################################
$f = XML::XPath->new( filename => $_[0]);


foreach my $c($f->find('//TEIL')->get_nodelist) {

         $filter_flag = $c->find('FILTER')->string_value;
		 
         if ($filter_flag eq "") { # Bei leerem FILTER auf Standard setzen.
		   $filter_flag = 0;
		 }
		 
    if ( $filter_flag == 0) {                                   # Nur Datensaetze mit FILTER = 0 aufnehmen.
		push (@temp, "");                                       # Feld F1 (standardmaessig leer)
		push (@temp, $c->find('ANZAHL')->string_value);
		push (@temp,  $c->find('BENENNUNG')->string_value);
		push (@temp,  $c->find('BEZEICHNUNG')->string_value);
		push (@temp,  $c->find('MATERIAL')->string_value);
		push (@temp,  $c->find('ARTIKELNUMMER')->string_value);
	
		$str_temp = $c->find('BEARBEITUNG')->string_value;       # Sonderbehandlung fuer die Bearbeitung.
		if ($str_temp eq "1") {                                  # Aus 0=>J und aus 1=>N.  
		    $str_temp = "J";
		} elsif ($str_temp eq "0") {
		    $str_temp = "N";
		} elsif ($str_temp eq "JA") {                            # Aus Kompatibilitaetsgruenden
		    $str_temp = "J";                                     # altes Verhalten auch beibehalten.
		}  elsif ($str_temp eq "NEIN") {
		    $str_temp = "N";
		}  elsif ($str_temp == "1.0") {
		    $str_temp = "J";
		}  elsif ($str_temp == "0.0") {
		    $str_temp = "N";
		}
		
		push (@temp,  $str_temp);
	
		push (@temp,  $c->find('NAME')->string_value);
		push (@temp, "");                                       # Feld F9 (standardmaessig leer)
		push (@temp,  $c->find('AS1')->string_value);
		push (@temp,  $c->find('AS2')->string_value);
		push (@temp,  $c->find('AS3')->string_value);
		push (@temp,  $c->find('AS4')->string_value);
		push (@temp,  $c->find('AS5')->string_value);
		push (@temp,  $c->find('AS6')->string_value);
		push (@temp,  $c->find('AS7')->string_value);
		push (@temp,  $c->find('AS8')->string_value);                # Bis F17

        # Fuer nachfolgenden Felder laufen die Daten 
		# erst durch einen kleinen Filter um die Felder bei
		# Bedarf zu leeren.
		$str_temp = cfilter($c->find('MATRIZENMATERIAL')->string_value);            # F18
		push (@temp, $str_temp);                                                    
		$str_temp = cfilter($c->find('SCHNITTSPIEL')->string_value);                # F19
		push (@temp, $str_temp); 
		$str_temp = cfilter($c->find('BESCHICHTUNG')->string_value);                # F20
		push (@temp, $str_temp); 
		$str_temp = cfilter($c->find('SCHERSCHRAEGE')->string_value);               # F21
		push (@temp, $str_temp); 

		$AoA[$int_i++] = [@temp];
		@temp = ();
		}
}
# print Dumper @AoA;

 $str_pro_nr = $f->find('STUECKLISTE/@PROJEKT');
 $str_werkzeug_id = $f->find('STUECKLISTE/@WKZID');
# print "$str_pro_nr\n";
# print "$str_werkzeug_id\n";

return (\@AoA, $str_werkzeug_id, $str_pro_nr); # Referenz auf das Array
}

#########################
# Kleiner Filter fuer
# Datenmuell
##########################
sub cfilter {
  my $str = $_[0];
  if ($str eq "-") {
  	$str = "";
  }
  elsif ($str eq "0.00") {
   $str = "";
  }
  else {
   $str = $_[0];
  }
}


###################################################
#
#
# Korrekte Stueckliste in einem Projektverzeichnis
# bestimmen.
#
#
###################################################
sub stueckliste_bestimmen {
	# Beispiel fuer Projektpfad: "/space/pass10/Zeich_3d/Proe/600/6008/600842/";
	my $str_projekt_root = "/space/pass10/Zeich_3d/Proe/";
	my $str_projekt_pfad = "dummy";
	my $str_projekt_nr = "dummy";
	my $str_projekt_muster = "*.bom.*";

	my $int_pos_punkt = 0;
	my $int_pos_us = 0;
	my $str_endung = "dummy";
	my $int_max = 0;
	my $int_dummy = 0;
	my $int_pos = 0;

	my @arr_liste = ();

	my $str_n = "dummy";
	my $int_i = 0;
	my $int_laenge = 0;

	my $str_eingabe = "dummy";
    my $str_err_msg;


	$str_projekt_nr = $_[0];
	# Pruefen ob die Projektnummer einen Unterstrich enthaelt, wenn ja diesen
	# hinteren Teil entfernen. Zusaetzlich das Suchmuster fuer die .bom-Datei
	# anpassen.
	$int_pos_us = rindex($str_projekt_nr,"_"); # Unterstrich suchen.
	$int_laenge = length($str_projekt_nr);
	
	
    if ($int_pos_us != -1) {
 		print "I1 select_file: $str_projekt_nr enthaelt einen Unterstrich.\n";
		
	    $str_projekt_muster = "*".substr($str_projekt_nr,$int_pos_us,($int_laenge-$int_pos_us)).".bom.*"; # Suchmuster mit Unterstrich
 		print "I3 select_file: Korrigiertes Projektmuster: $str_projekt_muster.\n";
		
		$str_projekt_nr = substr($str_projekt_nr,0,$int_pos_us); # Unterstrich abschneiden.
 		print "I2 select_file: Korrigierte Projektnummer: $str_projekt_nr\n";
		
	}

	# Ueberpruefen ob die Projektnummer eine ganze Zahl ist.
	if ( ! ($str_projekt_nr =~ /^\d+$/ and $str_projekt_nr <= 999999) ) {
	    
 		$str_err_msg =  "Error: select_file:  $str_projekt_nr ist keine ganze Zahl oder groesser als 999999!\n";
		print $str_err_msg;
		return ($str_err_msg);
		 
}

	####################################################
	#  Den exakten Projektpfad zusammensetzen.
	####################################################
	$str_projekt_pfad = $str_projekt_root.substr($str_projekt_nr,0,3)."/".substr($str_projekt_nr,0,4)."/".$str_projekt_nr."/";
	# print "select_file: Projektpfad: $str_projekt_pfad\n\n";

	if (! (-e  $str_projekt_pfad) ) { 
	
		$str_err_msg =  "Error: select_file: Projektpfad existiert nicht!\n";
		print $str_err_msg;
		print "Error: select_file: $str_projekt_pfad\n";
		return ($str_err_msg);
				 
	}	

	####################################################
	# Kandidaten auswaehlen.
	###################################################
	@arr_liste = <$str_projekt_pfad$str_projekt_muster>;
	$int_laenge = @arr_liste;
	if ( $int_laenge == 0 ) {
		$str_err_msg =  "Error: select_file: Keine Stueckliste im Projektpfad gefunden!\n";
		print $str_err_msg;
	    print "Error: select_file: $str_projekt_pfad\n";	
		return ($str_err_msg);
	}

	###################################################
	# Ausgabe 
	###################################################
	$int_i = 0;
	foreach $str_n (@arr_liste) {
		print "I4 select_file: $str_n\n";               # Verzeichnis mit Datei ausgeben

	    $int_laenge = length($str_n);       		# Laenge von Pfad/Datei ermitteln.
	
		$int_pos_punkt = rindex($str_n,".");		# Position des letzten Punktes ermitteln.
		# print "$int_pos_punkt    ";
	
		$str_endung =  substr($str_n,$int_pos_punkt + 1,$int_laenge)."\n"; # Ab Postion des letzten Punktes bis Stringende abschneiden.
		# print "  $str_endung";                    # Extrahierte Endung

		# Maximumbestimmung waehrend des Durchlaufes.
		$int_dummy = $str_endung;				# Formale Zuweisung an eine Integer;
		if ( $int_dummy > $int_max ) {				# Ist die momentane Zahl groesser als ihr Vorgaenger?
			$int_max = $int_dummy;				# Dann ist sie die neue groesste Zahl.
			$int_pos = $int_i;				# Position innerhalb des Arrays merken.
		}
		$int_i++;
	}


		# print "select_file: Maximum: $int_max";     # Ermitteltes Maximum

	# Bildschirmausgabe
	print "I5 select_file: $arr_liste[$int_pos]\n";
	
	return("$arr_liste[$int_pos]");
}
