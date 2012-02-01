############################################################
#  Erzeugt das File 'computer.txt' für 'hinventory.vbs'
#  aus dem Active-Directory.
#
# (jb) 2012
############################################################

use strict;
use warnings;

use Data::Dumper;
use Getopt::Std;

use Hinventory_Moose_AD;

my %opts;

getopts('hsd', \%opts);


my $obj =  Hinventory_Moose_AD->new();


# Hilfe.
if (defined $opts{h}) 
{
print "gen_computer_txt.pl [-d] [-h]\n\n";
print "-h Hilfe\n";
print "-d Diff zur Referenz-Datei erzeugen.\n";
exit 0;
}

# Diff-Durchlauf.
if (defined $opts{d}) 
{
print "Diff-Durchlauf\n";
print "xml_dir: ", $obj->xml_dir, "\n";
print "filepattern: ", $obj->filepattern,"\n";

$obj->gen_computer_txt_ad_diff();
exit 0;
}

# Normal-Durchlauf.
print "Normal-Durchlauf\n";
print "dest_file: ", $obj->dest_file, "\n";
print "blacklist_file: ", $obj->blacklist_file,"\n";

$obj->gen_computer_txt_ad(); 
exit 0;
