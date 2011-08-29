############################################################
# Check-XML.
#
# (jb) 2011
############################################################

use strict;
use warnings;

use XML::LibXML;
use Getopt::Std;

my $file_name;
my %opts;



getopts('i:h', \%opts);

if (defined $opts{h}) {
	print "check_xml.pl -i [-h]\n\n";
	print "-h Hilfe\n";
	print "-i Eingabedatei\n";
	exit 1;
}

if (defined $opts{i}) {
	$file_name = $opts{i};

} else {
	print "Eingabedatei angeben.\n";
	print "check_xml.pl -i foo.xml\n";
	exit 0;
}

#########################################
# Files aus XML-Konformitaet pruefen.
#########################################
my $parser = XML::LibXML->new();

eval {my $doc = $parser->parse_file( $file_name ); };

print "$@"."\n" if( $@ );     # Nein? Dann Fehlermeldung ausgeben.
1;
