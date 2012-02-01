############################################################
# hinventory mit LibXML und XPATH filtern.
# Ausgabe mit dem Template Toolkit.
# (jb) 2011
############################################################

use strict;
use warnings;

# use Data::Dumper;


# CPAN
use Path::Class;
# Standard-Module
use FindBin '$Bin';
use Getopt::Std;

# Hilfsfunktionen für Hinventory 
use Hinventory;

my %opts;
my $cmd_str_type = "Application";
my $cmd_str_name = "Firefox";

my $str_path;

##################################
# Optionen verarbeiten.
##################################
getopts('dhi:t:n:', \%opts);

if (defined $opts{t}) 
{
$cmd_str_type = $opts{t};
}

if (defined $opts{n}) 
{
$cmd_str_name = $opts{n};
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
$str_path = file($Bin,"xml", $opts{i});
} 
else 
{
#########################################
# Eingabefiles selektieren (Wildcard).
#########################################
my $str_filepattern = "*.xml";
$str_path = file($Bin,"xml", $str_filepattern);
}


###########################################################
#                       HAUPTTEIL
###########################################################
my $recordset_ref = []; # Anonymes Array für die Datensätze.

hinventory_gen_recordset($recordset_ref, $cmd_str_type, $cmd_str_name, $str_path);

if (defined $opts{d}) 
{
# Ausgabe auf Bildschirm im Textformat.
hinventory_print_recordset($recordset_ref);
} 
else 
{
# Ausgabe auf Bildschirm im HTML.
hinventory_gen_html($recordset_ref);
}
1;
