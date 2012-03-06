#!/usr/bin/perl -w 

####################################################
# Sucht ungueltige Email-Adressen in ANSPRECHPARTNER 
#
# (jb) April 2009
####################################################

use strict;
use warnings;
use DBI;


my $str_user = 'user1';
my $str_password = 'xxxxxxxxxxxxxxx';

	###############################################
	# Zur Datenbank verbinden.
	###############################################
	 my $dbh = DBI->connect("dbi:Sybase:server=server2000", $str_user, $str_password, {PrintError => 0}) 
		or die "Unable for connect to server $DBI::errstr";


	###############################################
	# SQL-String festlegen und ausfuehren.
	################################################
	my $sql;
        my $sth;
	$sql = "use PASS;";
	print ("SQL-Kommando fuer SQL-Server:    $sql\n");

	$sth = $dbh->prepare($sql)
		or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
	
	$sth->execute()
		or die "Can't execute SQL Statement: ",$sth->errstr(), "\n";



	$sql = "select ZAEHLER, LFN ,EMAIL from ANSPRECHPARTNER;";
	print ("SQL-Kommando fuer SQL-Server:    $sql\n\n\n");

	$sth = $dbh->prepare($sql)
		or die "Can't prepare SQL Statement: ",$sth->errstr(), "\n";
	
	$sth->execute()
		or die "Can't execute SQL Statement: ",$sth->errstr(), "\n";
    #################################################
	# Pause.
	#################################################
	#sleep(10);



	
	while (@row = $sth->fetchrow_array) {
	 
     ##############################################	
	 # Check for valid Email.
	 ##############################################
	 if ( $row[2] ) {
		
		if ( $row[2] =~ /^[^@]+@([-\w]+\.)+[A-Za-z]{2,4}$/ ) {
		   # Do nothing
		} else {
		    print "Ungueltige Email-Adresse:                     $row[0]    $row[1]    $row[2]\n";
            			
		}

		
	 }
}

exit 0;		
