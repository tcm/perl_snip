############################################################
# HTML-Reports via XSLT.
#
# (jb) 2011
############################################################
use strict;
use warnings;

# import required modules
use XML::XSLT;
use Getopt::Std;

# define local variables
my $xmlfile;
my $xslfile = "hinventory.xsl";
my $ziel_datei = "adam.htm";
my %opts;


getopts('i:h', \%opts);

if (defined $opts{h}) {
	print "gen_html_report_via_xslt.pl -i [-h]\n\n";
	print "-h Hilfe\n";
	print "-i Eingabedatei\n";
	exit 1;
}

if (defined $opts{i}) {
	$xmlfile = $opts{i};

} else {
	print "Eingabedatei angeben.\n";
	print "gen_html_report_via_xslt.pl -i foo.xml\n";
	exit 0;
}


# create an instance of XSL::XSLT processor
my $xslt = eval { XML::XSLT->new($xslfile, warnings => 1, debug
=> 0) };

# error handling here ...
if ($@) {
        die("Sorry, Could not create an instance of the XSL
Processor using $xslfile.\n");
}

# load XML
eval { $xslt->open_xml($xmlfile) };

# .. here ...
if ($@) {
        die("Sorry, Could not load XML file, $xmlfile.\n");
}

# transform XML file
eval { $xslt->process(debug => 0) };

# .. and here.
if ($@) {
        die("Sorry, Could not transform XML file, $xmlfile.\n");
}

# send to output
# print $xslt->toString;



##########################################################
# In File schreiben. 
###########################################################
open my $ziel_fh, '>', $ziel_datei || die "$ziel_datei konnte nicht geoeffnet werden.\n"; 
print $ziel_fh $xslt->toString;
close ($ziel_fh);


# free up some memory
$xslt->dispose();
 
