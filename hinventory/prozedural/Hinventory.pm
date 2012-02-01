package Hinventory;

use strict;
use warnings;

# CPAN
use XML::LibXML;
use Path::Class;
use Template;
# Standard-Module
use Carp 'croak';
use File::Basename;
use File::Glob ':glob';
use FindBin '$Bin';
use File::stat;
use CGI;
use POSIX qw( strftime );


use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

require Exporter;

our $VERSION = 0.1;
our @ISA = qw(Exporter);
our @EXPORT = qw(hinventory_gen_recordset hinventory_gen_html hinventory_print_recordset);
our @EXPORT_OK = qw(hinventory_gen_recordset hinventory_gen_html hinventory_print_recordset);
our %EXPORT_TAGS = ( Functions => [ qw(hinventory_gen_recordset hinventory_gen_html hinventory_print_recordset) ] );


###########################################################
#  Recordset erzeugen.
#
#  Parameter:
#  1. Referenz auf ein anonymes Array.
#  2. XML-Type-Tag (exakt).
#  3. XML-Name-Tag (Regex).
#  4. Pfad zu den XML-Files.
###########################################################
sub hinventory_gen_recordset 
{

   croak "4 Argumente erwartet aber " . @_." erhalten."
   unless @_ == 4;

   my ($AOH_ref, $str_type, $str_name, $str_path) = @_;

   my $n1 = 0; # Zähler für alle Files.
   my $n2 = 0; # Zähler nur für die Treffer.

   my @files = bsd_glob "$str_path";
   foreach my $file (@files) 
   {
      #########################################
      # Files auf XML-Konformitaet pruefen.
      #########################################
      my $filename = basename($file);
      my $parser = XML::LibXML->new();
      my $tree;

      eval {$tree = $parser->parse_file( $file ); };

      if( $@ ) 
      {     								# Nein? Dann Fehlermeldung ausgeben.
      print "\n\nXML-Fehler in: $filename\n\n";
      # print $@."\n";              					# Exakte Meldung ausgeben.
      } 
      else 
      {	        						      # Ja? Dann normal verarbeiten.
      my $stat_epoch = stat( $file )->ctime;                          # Fileattribute auslesen.
      #########################################
      # Begriffe in allen Files suchen.
      #########################################
      $n1++;
      my $root = $tree->getDocumentElement;
      foreach my $component ($root->findnodes('component')) 
      {		    
         if ( $component->findvalue('type') eq $str_type) 
	 {
	 my $name = $component->findvalue('name');
	 if ($name =~ /$str_name/) 
	 {				
	 # Zeile generieren.
	 push(@{ $AOH_ref }, 
	 { 
	 count => $n2, 
	 filename => $filename, 
	 name => $name, 
	 createtime =>  strftime('%d-%m-%Y %H:%M', localtime( $stat_epoch ))  
         });
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
sub hinventory_gen_html 
{
   croak "1 Argument erwartet aber " . @_." erhalten."
   unless @_ == 1;

   my $recordset_ref = shift;

   $| = 1;
   #print "Content-type: text/html\n\n";

   my $file = 'html.tt';
   my $vars = 
   {
   'version' => 0.9,
   'email' => "edv\@pass-ag.com",
   'recordset' => $recordset_ref,
   'cgi' => CGI->new()	   
   };


   my $template = Template->new(
   {
   INCLUDE_PATH => file($Bin,"templates"),
   INTERPOLATE => 1
   });

   $template->process($file, $vars)
      || die $template->error();	    
}

###########################################################
#  Bildschirmausgabe Recordset.
#
#  Parameter: Referenz auf ein AoH
###########################################################
sub hinventory_print_recordset 
{
   croak "1 Argument erwartet aber " . @_." erhalten."
   unless @_ == 1;

   my $recordset_ref = shift;

   # print Dumper $recordset_ref;	
   foreach my $rec ( @{ $recordset_ref }  ) 
   { 
      printf "%3d.) %15s   %40s   %30s\n",
      $rec->{'count'},
      $rec->{'filename'},
      $rec->{'name'},
      $rec->{'createtime'};
   }
}
1;
