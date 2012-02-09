#!/usr/bin/perl 

use strict;
use warnings;

############################################################
# Einen Test-SELECT machen. 
# Bei Fehler ein Reconncet probieren und vorher alle
# Firebird-Prozesse beeenden.
#
# (jb) 07.02.2012
############################################################

use DBI;                # Das DBI-Modul laden
use POSIX qw(strftime);


my %attr = ( PrintError => 0, RaiseError => 0);

##########################################################
#  
# Variablen-Deklaration
#
###########################################################



############################################################
# Datenbankverbindungsparameter.
############################################################

my $str_dsn = "dbi:InterBase:localhost:/space/pass/Firebird/database.gdb";
my $str_user = "user";
my $str_password = "password";

my $sec_reconnect = ( 5 * 60 );
my $sec_query_wait = ( 2 * 60 );
my $timestamp;

while (1) 
{  
   my $dbh;

   #############################################################
   # Verbindung zur Datenbank herstellen.
   #############################################################
   until  (   $dbh = DBI->connect($str_dsn, $str_user, $str_password, \%attr )   )
   {
      
      print"Waiting $sec_reconnect (sec) before reconnecting.\n";
      sleep( $sec_reconnect );

      warn "Can't connect: $DBI::errstr. Pausing before retrying.\n";
      $timestamp =  strftime "[%d/%m/%Y] %H:%M:%S\n", localtime;
      print $timestamp;

      system("/root/scripts/firebird_service/kill_all_firebird_processes.sh");
      system("echo '' | mail -s 'Firebird processes killed: dbhost' admin\@domain.com");

   }


   eval 
   {
      $dbh->{RaiseError} = 1;

      #############################################################
      # SQL-Anweisung vorbereiten und Parameter uebergeben.
      #############################################################
      my $id = int(rand(100000)+1);
      my $sql = "SELECT * FROM SP_PROC1($id)";
      $timestamp = strftime "[%d/%m/%Y] %H:%M:%S       ", localtime;
      print $timestamp, $sql,"\n";
      my $sth = $dbh->prepare ( $sql );
      

      $sth->execute();
      my $rows =$sth->dump_results; 
      $sth->finish;
         
      $dbh->disconnect;
      # Pause
      print"Waiting $sec_query_wait (sec).\n";
      sleep($sec_query_wait);

    };
    warn "Monitoring aborted by error: $@\n" if $@;

}
