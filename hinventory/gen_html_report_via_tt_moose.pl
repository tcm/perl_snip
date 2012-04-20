############################################################
# hinventory mit LibXML filtern.
# Ausgabe mit dem Template Toolkit.
#
# (jb) 2012
############################################################

use strict;
use warnings;

use Data::Dumper;


# CPAN
use Path::Class;
# Standard-Module
use FindBin '$Bin';
use Getopt::Std;

use Hinventory_Moose_Query;

my %opts;

my $obj = Hinventory_Moose_Query->new();


##################################
# Optionen verarbeiten.
##################################
getopts('dhi:t:n:', \%opts);

if (defined $opts{t}) 
{
$obj->set_type($opts{t});
}

if (defined $opts{n}) 
{
$obj->set_name($opts{n});
}

if (defined $opts{h}) 
{
print "gen_html_report_via_tt.pl [-d] [-h] [-i] [-t <type>] [-n <name>]\n\n";
print "Example: query_xml_xpath.pl -t Application -n NET\n";
print "-d Debug\n";
print "-h Hilfe\n";
print "-i Eingabefile\n";
print "-t Typ angeben (Default=Application)\n";
print "-n Name angeben (Default=Firefox)\n";
exit 1;	
}

if (defined $opts{i}) 
{
#########################################
# Eingabefile selektieren.
#########################################
my $str_file = file($Bin,"xml", $opts{i});
$obj->set_files( "$str_file" );
}
#else
#{
#my $str_file = file($Bin,"xml", "*.xml");
#$obj->set_files( "$str_file" );
#}



##########################################################
#                       HAUPTTEIL
###########################################################
my $recordset_ref = []; # Anonymes Array für die Datensätze.

$obj->print_attributes();
$obj->hinventory_gen_recordset($recordset_ref);

#print Dumper $recordset_ref;


if (defined $opts{d}) 
{
# Ausgabe auf Bildschirm im Textformat.
$obj->hinventory_print_recordset($recordset_ref);
} 
else 
{
# Ausgabe auf Bildschirm im HTML.
$obj->hinventory_gen_html($recordset_ref);
}
exit 0;
