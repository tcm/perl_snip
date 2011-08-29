############################################################
# hinventory mit LibXML und XPATH filtern.
#
# (jb) 2011
############################################################

use strict;
use warnings;

use Data::Dumper;

# CPAN
use XML::LibXML;
use Path::Class;
# Standard-Module
use File::Basename;
use File::Spec;
use File::Glob ':glob';
use FindBin '$Bin';
use Getopt::Std;
use File::stat;


my %opts;
my $str_type = "Application";
my $str_name = "Firefox";
my $n1 = 0; # Zähler für alle Files.
my $n2 = 0; # Zähler nur für die Treffer.
my $str_path;


getopts('hi:t:n:', \%opts);

if (defined $opts{t}) {
	$str_type = $opts{t};
}

if (defined $opts{n}) {
	$str_name = $opts{n};
}

if (defined $opts{h}) {
	print "query_xml_xpath.pl [-h] [-i] [-t <type>] [-n <name>]\n\n";
	print "Example: query_xml_xpath.pl -t Application -n NET\n";
	print "-h Hilfe\n";
	print "-i Eingabefile\n";
	print "-t Typ angeben (Default=Application)\n";
	print "-n Name angeben (Default=Firefox)\n";
        exit 1;	
}

if (defined $opts{i}) {

	#########################################
	# Eingabefile selektieren.
	#########################################
	$str_path = file($Bin,"xml", $opts{i});
	# $str_path = File::Spec->catfile( $Bin,"xml", $opts{i} );
	

} else {

	#########################################
	# Eingabefiles selektieren (Wildcard).
	#########################################
	my $str_filepattern = "*.xml";
	$str_path = file($Bin,"xml", $str_filepattern);
	# $str_path = File::Spec->catfile( $Bin,"xml", $str_filepattern );

}



print "\n";

my @files = bsd_glob "$str_path";
foreach my $file (@files) {

#########################################
# Files auf XML-Konformitaet pruefen.
#########################################
my $filename = basename($file);
my $parser = XML::LibXML->new();
my $tree;

eval {$tree = $parser->parse_file( $file ); };

if( $@ ) {     											# Nein? Dann Fehlermeldung ausgeben.
	print "\n\nXML-Fehler in: $filename\n\n";
	# print $@."\n";									# Exakte Meldung ausgeben.

} else {											# Ja? Dann normal verarbeiten.

	my $sb = stat($file);                                                                   # Fileattribute auslesen.
	#########################################
	# Begriffe in allen Files suchen.
	#########################################
	$n1++;
	my $root = $tree->getDocumentElement;


	foreach my $component ($root->findnodes('component')) {

	    # my $type = $component->findvalue('type');
	    if ( $component->findvalue('type') eq $str_type) {

		    my $name = $component->findvalue('name');
	            if ($name =~ /$str_name/) {
			printf "%3d.) %15s   %40s   %30s\n",++$n2, $filename, $name, scalar localtime $sb->ctime;
	 	    }
		    # print "$type\n";
    	    }
	}

        # Example:
	# foreach my $camelid ($root->findnodes('species')) {
	#    my $latin_name = $camelid->findvalue('@name');
	#    my $common_name = $camelid->findvalue('common-name');
	#    my $status =  $camelid->findvalue('conservation/@status');
	#    print "$common_name ($latin_name) $status \n";
	#}
	
 	}
}

print "\n\n\--------------------------------------------------------------\n";
print "Dateien verarbeitet: $n1\n";
print "Suchpfad: $str_path\n";
print "Parameter: component type=$str_type name=$str_name"."\n\n";
1;
