#!/usr/bin/perl -w 

##############################################
# Auslieferungen fuer diesen Tag nach Kunde.
# Einzel-Email an den Kunden. 
# Report an den Admin.
#
# (jb) Maerz 2009
##############################################

use strict;
use warnings;
use DBI;
use POSIX qw(strftime);


my $str_lieferdatum = strftime "%m/%d/%Y", localtime;
# my $str_lieferdatum = "02/27/2012";

my $email_alias = "admin\@pass-lokal.com";
my $transfer_file = "./auslieferungen.txt";
my $transfer_file_2 = "./auslieferungen_info.txt";

my $str_user = 'user1';
my $str_password = 'xxxxxxxxxxxx';
my $str_space = "                       ";
my $s1="";
my $s2="";
my $s3="";
my $work_dir = "/root/scripts/automail";

	###############################################
	# Zur Datenbank verbinden.
	###############################################
	 my $dbh = DBI->connect("dbi:Sybase:server=sqlserver", $str_user, $str_password, {PrintError => 0}) 
		or die "Unable for connect to server $DBI::errstr";


	###############################################
	# SQL-String festlegen und ausfuehren.
	###############################################
	my $sth;
        my $sql;        

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

        chdir($work_dir);

	my %email1;
	while (my @row = $sth->fetchrow_array) {
	 
         ##############################################	 
	 # Recordset in Hash speichern.
	 # Hash-Schluessel ist die Emailadresse.
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

         my $fh_afile;
	 foreach my $key (keys %email1) {
       
	    #########################################
	    # Email fuer Kunden zusammen stellen.
	    #########################################
	    open my $fh_kfile, ">", "$transfer_file" or die "Can't open $transfer_file: $!";
	    print $fh_kfile "$email1{$key}\n";
	    close $fh_kfile or die "Error closing file: $!\n";
		
	    #########################################
	    # Email fuer Admin zusammenstellen.	
	    #########################################
	    open $fh_afile, ">>", "$transfer_file_2" or die "Can't open $transfer_file: $!";
	    print $fh_afile "$key:\n$email1{$key}\n";

	   ##################################################
	   # Dateien per Email wegschicken.
	   ##################################################
	   if ( -s $transfer_file ) {
	       system("cat $transfer_file | mail -s \'Auslieferungen PASS Stanztechnik AG\' $key");
	       # system("cat $transfer_file | mail -s \'Auslieferungen PASS Stanztechnik AG\' $email_alias");
	   } else {
    	       print ("$transfer_file existiert nicht oder hat 0 Bytes\n");
	   }
		
	}					

        if ( -s $transfer_file_2) {
 	        close $fh_afile or die "Error closing file: $!\n";
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
