###################################
# Häufigkeitsverteilung
# von XML-Tags bestimmen.
#
# (jb) 2011
###################################

use XML::LibXML;
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
my $tree;
my %dist;

eval {$doc = $parser->parse_file( $file ); };

if( $@ ) 
{     								# Nein? Dann Fehlermeldung ausgeben.
print "\n\nXML-Fehler in: $file\n\n";
# print $@."\n";              					# Exakte Meldung ausgeben.
} 
else 
{	       						        # Ja? Dann normal verarbeiten.
&proc_node( $doc->getDocumentElement, \%dist );
foreach my $item ( sort keys %dist ) 
{
   print "$item: ", $dist{ $item }, "\n";
}

}
exit 0;

############################################################
# Baumknoten verarbeiten:
# Wenn ein Element gefunden wird, die Hashliste
# aktualisieren und alle seine Kinder verarbeiten.
############################################################
sub proc_node 
{
    my( $node, $dist ) = @_;

    return unless( $node->nodeType eq &XML_ELEMENT_NODE );
   
    $dist->{ $node->nodeName }++;
    foreach my $child ( $node->getChildnodes ) 
    {
       &proc_node( $child, $dist );
    }
}

