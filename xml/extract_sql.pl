############################################################
# Parsing von SQL-Server Profiler Files.
#
# (jb) 2011
############################################################

use XML::LibXML;
#use IO::Handle;
use Getopt::Std;
use Data::Dumper;


my %opts;
my $file;

##################################
# Optionen verarbeiten.
##################################
getopts('hi:', \%opts);


if (defined $opts{h}) 
{
print "frequency_libxml.pl [-h] [-i] <Eingabefile>\n\n";
print "Example: frequency_libxml.pl -i test.xml\n";
print "-h Hilfe\n";
print "-i Eingabefile\n";
exit 0;	
}

if (defined $opts{i}) 
{
#########################################
# Eingabefile selektieren.
#########################################
$file = $opts{i};
} 
else 
{
print "Kein Eingabefile angegeben.\n";
exit 1;
}


# Parser intialieren.
my $parser = new XML::LibXML;

my $parser = XML::LibXML->new();
my $doc;


eval {$doc = $parser->parse_file( $file ); };

if( $@ ) 
{     								# Nein? Dann Fehlermeldung ausgeben.
print "\n\nXML-Fehler in: $file\n\n";
# print $@."\n";              					# Exakte Meldung ausgeben.
} 
else 
{

my $xc = XML::LibXML::XPathContext->new($doc);
#$xc->registerNs('xml', 'http://tempuri.org/TracePersistence.xsd');
# my @nodes = $xc->findnodes('//xhtml:p');


# Fuer camelid.xml
#my @nodes = $xc->findnodes('//species');
#print Dumper @nodes;

#foreach my $element ( @nodes )
#{
#   my $value = $element->findvalue( 'common-name' );
#   print $value."\n";
#}

my @nodes = $xc->findnodes('//Event');

#print Dumper @nodes;

foreach my $element ( @nodes )
{
	my $value = $element->findvalue('Column[@name=\'TextData\']');
	print $value."\n";
}
}
exit 0;
