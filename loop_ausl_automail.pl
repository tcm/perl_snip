#!/usr/bin/perl -w 

##############################################
# Auslieferungen fuer diesen Tag nach Kunde.
# Einzel-Email an den Kunden. Report an den
# Admin.
#
# (jb) Maerz 2009
##############################################

use DBI;

$str_lieferdatum = &zeitstempel(); 
#$str_lieferdatum = "12/18/2007";

$email_alias = "admin\@pass-lokal.com";
$transfer_file = "./auslieferungen.txt";
$transfer_file_2 = "./auslieferungen_info.txt";

$str_user = 'user1';
$str_password = 'xxxxxxxxxxxxx';
$str_space = "                       ";
$s1="",$s2="",$s3="";
$work_dir = "/root/scripts/automail";

	###############################################
	# Zur Datenbank verbinden.
	###############################################
	 my $dbh = DBI->connect("dbi:Sybase:server=server2000", $str_user, $str_password, {PrintError => 0}) 
		or die "Unable for connect to server $DBI::errstr";


	###############################################
	# SQL-String festlegen und ausfuehren.
	################################################
	$sql = "use PASS;";
	print ("SQL-Kommando fuer SQL-Server:    $sql\n");

	$sth = $dbh->prepare($sql)
		or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
	
	$sth->execute()
		or die "Can't execute SQL Statement: ",$sth->errstr(), "\n";



	$sql = "exec Infoexport_Auslieferungen \'$str_lieferdatum\'";
	print ("SQL-Kommando fuer SQL-Server:    $sql\n");

	$sth = $dbh->prepare($sql)
		or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
	
	$sth->execute()
		or die "Can't execute SQL Statement: ",$sth->errstr(), "\n";
    #################################################
	# Pause.
	#################################################
	#sleep(10);


    chdir($work_dir);

	my %email1;
	
	while (@row = $sth->fetchrow_array) {
	 
     ##############################################	 
	 # Recordset in Hash speichern.
	 # Hash Schluessel ist die Emailadresse.
	 ##############################################
	    $s1 = substr($row[2].$str_space,0,16);
		#print "$s1\n";
	    $s2 = substr($row[4].$str_space,0,28);
		#print "$s2\n";
	    $s3 = substr($row[5].$str_space,0,21);
		#print "$s3\n";
		
     if ($email1{$row[0]}) {	 
	    # Schon ein Eintrag fuer diese Email-Adresse vorhanden?
		# Wenn ja, dann String anhaengen.
		
	 	$email1{$row[0]} = $email1{$row[0]}.$s1.$s2." ".$s3."\n";
		
	 }
	 else {
	    # Wenn nein, dann Kopf und neuen Schluessel anlegen.
	    $email1{$row[0]} = "Unsere KOMNR:   Ihre Bestell-Nr:             UPS/DHL-Nummer:\n";
	 	$email1{$row[0]} = $email1{$row[0]}.$s1.$s2." ".$s3."\n";
	 }
	 
	 
	}
	$sth->finish();

     my $key;
	 foreach $key (keys %email1) {
       
	    #########################################
	    # Email fuer Kunden zusammen stellen.
		#########################################
	    open FILE, ">$transfer_file" or die "Can't open $transfer_file: $!";
	 	print FILE "$email1{$key}\n";
	    close FILE or die "Error closing file: $!\n";
		
		#########################################
	    # Email fuer Admin zusammenstellen	
		#########################################
	    open FILE2, ">>$transfer_file_2" or die "Can't open $transfer_file: $!";
	 	print FILE2 "$key:\n$email1{$key}\n";
		
	 
	 

		##################################################
		# Dateien per Email wegschicken.
		##################################################
		if ( -s $transfer_file ) {
	         system("cat $transfer_file | mail -s \'Auslieferungen PASS Stanztechnik AG\' $key");
	         #system("cat $transfer_file | mail -s \'Auslieferungen PASS Stanztechnik AG\' $email_alias");
		} else {
    	     print ("$transfer_file existiert nicht oder hat 0 Bytes\n");
		}
		
	}					

        if ( -s $transfer_file_2) {
 			close FILE2 or die "Error closing file: $!\n";
		    system("cat $transfer_file_2 | mail -s \'Auslieferungen-Info\' $email_alias");
			unlink("$transfer_file_2") or die "Error deleting file: $!\n";
		} else {
			print ("$transfer_file_2 existiert nicht oder hat 0 Bytes\n");
	}
	
	###################################################
	# Verbindung abbauen.
	###################################################
	$dbh->disconnect() 
		or warn "Disconnect failed : $DBI::errstr\n";

exit 0;

################################################
# Unterprogramm : Zeitstempel
# Die aktuelle Zeit bestimmen.
#
################################################
sub zeitstempel {

	local ($seconds,$minutes,$hours,$day,$month,$year);
	local ($str_zeitstempel);

	($seconds, $minutes, $hours, $day, $month, $year) = (localtime)[0,1,2,3,4,5];
	$month += 1;
	$year  += 1900;

	$seconds = substr("00".$seconds,-2);
	$minutes = substr("00".$minutes,-2);
	$hours = substr("00".$hours,-2);
	$day = substr("00".$day,-2);
	$month = substr("00".$month,-2);

$str_zeitstempel = "$month/$day/$year";
$str_zeitstempel;
}
