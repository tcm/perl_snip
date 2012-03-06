#!/usr/bin/perl  

use strict;
use warnings;

use DBI;
use Data::Dumper;


############################################################################################
# Verbindung zur Datenbank herstellen.
############################################################################################
my $dbh = DBI->connect( "dbi:Sybase:server=server2008", 'user', 'password', { PrintError => 1 } )
  or die "Unable for connect to server $DBI::errstr";

my $sql = "use PASS;";
my $sth = $dbh->prepare($sql);
$sth->execute();


$sql = "select teilenummer,bezeichnung from TEILELISTE;";
$sth = $dbh->prepare($sql);
$sth->execute();

my $zu_lange_bezeichnung = 0;
my $n = 0;
while ( my @row = $sth->fetchrow_array ) 
{
   # Schleife um die Datensaetze mit den ausgelesenen Feldnamen zu erzeugen.
   for ( my $int_i = 0 ; $int_i < $sth->{NUM_OF_FIELDS} ; $int_i++ ) 
   {
      # MEMO-Felder muessen speziell gefiltert werden.
      if ( $sth->{NAME}->[$int_i] eq "bezeichnung" ) 
      {
      $zu_lange_bezeichnung = &count_char_per_line($row[$int_i]);
      }
   }

   
   # Teilenummer mit ausgeben.
   if ($zu_lange_bezeichnung == 1)
   {
   $n++;
   print $row[0],"\n";
   print "-------------[$n]-------------------------\n";
   $zu_lange_bezeichnung = 0;
   }
   
   
}

$dbh->disconnect();

exit 0;



######################################
# Newlines aus einem String entfernen.
#
######################################
sub remove_newline {
   my $byte;
   my $str_new;
  
   # Wir filten die Zeilenschaltung aus  String.
   foreach $byte  (split(//, $_[0])) 
   {
      # print $byte;
      $byte = "-" if ($byte eq chr(10));
      $byte = "<" if ($byte eq chr(13));
      $str_new = $str_new.$byte;
    }
	
   $str_new;
}

##########################################
# Zeichen pro Zeile zaehlen.
#
##########################################
sub count_char_per_line {
   my @arr1 = split(/\n/, $_[0]);
   my $max_len = 25;
   my $is_greater = 0;

   foreach my $line ( @arr1 )
   {
      
      my $len = length($line);

      if ( $len > $max_len )
      {
      print $len,"  ";
      chomp($line);
      print $line,"\n";
      $is_greater  = 1;
      }
   }
   $is_greater;
}
