#!/usr/bin/perl -w 

use strict;
use DBI;
use Data::Dumper;
use XML::Writer;
use IO::File;

my $str_sql =
  "select indexnummer,komnr,text from bestellungen where indexnummer = 528723;";
my @row;

my $int_i   = 0;
my $int_pos = 0;

############################################################################################
# Verbindung zur Datenbank herstellen.
############################################################################################
my $dbh = DBI->connect( "dbi:Sybase:server=server2000", 'user', 'password',
	{ PrintError => 0 } )
  or die "Unable for connect to server $DBI::errstr";

my $sth = $dbh->prepare($str_sql);
$sth->execute();

my $output = new IO::File(">output_writer.xml");
my $writer = new XML::Writer(OUTPUT => $output, DATA_MODE => 1, IDENT_MODE => 1);


$writer->xmlDecl('ISO-8859-1','yes');
$writer->pi('xml-stylesheet','type="text/xsl", href="test.xsl"');

$writer->startTag("resultset",'statement' => $str_sql);

### Die einzelnen Datensaetze durchlaufen.
while ( @row = $sth->fetchrow_array ) {
    $writer->startTag("row");

	# Schleife um die Datensaetze mit den ausgelesenen Feldnamen zu erzeugen.
	for ( $int_i = 0 ; $int_i < $sth->{NUM_OF_FIELDS} ; $int_i++ ) {

		# MEMO-Felder muessen speziell gefiltert werden.
		if ( $sth->{NAME}->[$int_i] eq "text" ) {
		
		  $row[$int_i] = &remove_newline($row[$int_i]);
		  # print "$row[$int_i]\n";
		}
		
		$writer->dataElement($sth->{NAME}->[$int_i],$row[$int_i]);
	}
    $writer->endTag("row");
}

$writer->endTag("resultset");

#### Das Ende.
$writer->end();
$output->close();

$sth->finish();

######################################
# Newlines aus einem String entfernen.
#
######################################
sub remove_newline {
  my $byte;
  my $str_new;
  
  # Wir filten die Zeilenschaltung aus  String.
  foreach my $byte  (split(//, $_[0])) {
   	# print $byte;
   	$byte = "-" if ($byte eq chr(10));
   	$byte = "<" if ($byte eq chr(13));
   	$str_new = $str_new.$byte;
    }
	
   	$str_new;
}
