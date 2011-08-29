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
use Template;
# Standard-Module
use File::Basename;
#use File::Spec;
use File::Glob ':glob';
use FindBin '$Bin';
use Getopt::Std;
use File::stat;
use CGI;

my %opts;
my $cmd_str_type = "Application";
my $cmd_str_name = "Firefox";

my $str_path;


##################################
# Optionen verarbeiten.
##################################
getopts('hi:t:n:', \%opts);

if (defined $opts{t}) {
	$cmd_str_type = $opts{t};
}

if (defined $opts{n}) {
	$cmd_str_name = $opts{n};
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
	

} else {

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

# print "\n";

# print "Parse XML-Files...\n";
gen_recordset($recordset_ref, $cmd_str_type, $cmd_str_name, $str_path);

# print "Print Recordset...\n";
# print_recordset($recordset_ref);

# print "\n\n\--------------------------------------------------------------\n";
# print "Dateien verarbeitet: $int_files\n";
# print "Suchpfad: $str_path\n";
# print "Parameter: component type=$cmd_str_type name=$cmd_str_name"."\n\n";

#print "Generate HTML-Report...\n";
gen_html($recordset_ref);
1;


###########################################################
#  Bildschirmausgabe Recordset.
#
#  Parameter: Referenz auf ein AoH
###########################################################
sub print_recordset {

	my $recordset_ref = shift;

	# print Dumper $recordset_ref;
	
	for my $rec ( @{ $recordset_ref }  ) { 

		printf "%3d.) %15s   %40s   %30s\n",
		$rec->{'count'},
		$rec->{'filename'},
		$rec->{'name'},
		$rec->{'createtime'};

	}
}


###########################################################
#  Recordset erzeugen.
#
#  Parameter:
###########################################################
sub gen_recordset {
	my ($AOH_ref, $str_type, $str_name, $str_path) = @_;


	my $n1 = 0; # Zähler für alle Files.
	my $n2 = 0; # Zähler nur für die Treffer.

	my @files = bsd_glob "$str_path";
	foreach my $file (@files) {

		#########################################
		# Files auf XML-Konformitaet pruefen.
		#########################################
		my $filename = basename($file);
		my $parser = XML::LibXML->new();
		my $tree;

		eval {$tree = $parser->parse_file( $file ); };

		if( $@ ) {     								# Nein? Dann Fehlermeldung ausgeben.
			print "\n\nXML-Fehler in: $filename\n\n";
				# print $@."\n";					# Exakte Meldung ausgeben.
		} else {								# Ja? Dann normal verarbeiten.

			my $sb = stat($file);                                           # Fileattribute auslesen.
			#########################################
			# Begriffe in allen Files suchen.
			#########################################
			$n1++;
			my $root = $tree->getDocumentElement;
			foreach my $component ($root->findnodes('component')) {

		    
		    	if ( $component->findvalue('type') eq $str_type) {

				my $name = $component->findvalue('name');
	            		if ($name =~ /$str_name/) {
					
					# Zeile generieren.
					push(@{ $AOH_ref }, { count => $n2, 
							      filename => $filename, 
							      name => $name, 
							      createtime => scalar $sb->ctime  });
					$n2++;
		

	 	    		}
		    	
    	    	   	}
		    }
 	        }
		
 	}
# print "Dateien verarbeitet: $n1\n\n";
}


###########################################################
#  HTML-Report erzeugen.
#
#  Parameter: Referenz auf ein AoH
###########################################################
sub gen_html {
	my $recordset_ref = shift;

	$| = 1;
	#print "Content-type: text/html\n\n";

	my $file = 'html.tt';
	my $vars = {
	    'version' => 0.9,
	    'email' => "edv\@pass-ag.com",
	    'recordset' => $recordset_ref,
	    'cgi' => CGI->new()
	   
	};


	my $template = Template->new({
	    INCLUDE_PATH => file($Bin,"tt"),
	    INTERPOLATE => 1
	});

	$template->process($file, $vars)
	    || die $template->error();
	    

}


