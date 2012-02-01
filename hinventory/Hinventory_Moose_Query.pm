package Hinventory_Moose_Query;

use Moose;


has 'type'   => (isa => 'Str', is => 'rw', default => 'Application');
has 'name'   => (isa => 'Str', is => 'rw', default => 'Firefox');
has 'files'  => (isa => 'Str', is => 'rw', default => './xml/*.xml');

# CPAN
use XML::LibXML;
use Path::Class;
use Template;
# Standard-Module
use Carp 'croak';

use File::Basename;
use File::Copy;
use File::Glob ':glob';
use FindBin '$Bin';
use File::stat;

use CGI;
use POSIX qw( strftime );

#use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

#require Exporter;

#our $VERSION = 0.1;
#our @ISA = qw(Exporter);
#our @EXPORT = qw(hinventory_gen_recordset hinventory_gen_html hinventory_print_recordset gen_computer_txt_ad  gen_computer_txt_ad_diff);
#our @EXPORT_OK = qw(hinventory_gen_recordset hinventory_gen_html hinventory_print_recordset gen_computer_txt_ad  gen_computer_txt_ad_diff);
#our %EXPORT_TAGS = ( Functions => [ qw(hinventory_gen_recordset hinventory_gen_html hinventory_print_recordset gen_computer_txt_ad  gen_computer_txt_ad_diff) ] );

sub set_type 
{
   croak "2 Argumente erwartet aber " . @_." erhalten." unless @_ == 2;
   my ( $self, $type ) = @_;
   $self->type($type);
}

sub set_name 
{
   croak "2 Argumente erwartet aber " . @_." erhalten." unless @_ == 2;
   my ( $self, $name ) = @_;
   $self->name($name);
}

sub set_files
{
   croak "2 Argumente erwartet aber " . @_." erhalten." unless @_ == 2;
   my ( $self, $files ) = @_;
   $self->files($files);
}

sub print_attributes
{
   croak "1 Argument erwartet aber " . @_." erhalten." unless @_ == 1;
   my  $self = shift;

   print "type: ",$self->type,"\n";
   print "name: ",$self->name,"\n";
   print "files: ",$self->files,"\n";
}



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

      croak "2 Argumente erwartet aber " . @_." erhalten." unless @_ == 2;

      my ($self, $AOH_ref) = @_;

      my $n1 = 0; # Zähler für alle Files.
      my $n2 = 0; # Zähler nur für die Treffer.

      my @files = bsd_glob $self->files;
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
         print $@."\n";              					# Exakte Meldung ausgeben.
         } 
         else 
         {                 						# Ja? Dann normal verarbeiten.
         my $stat_epoch = stat( $file )->ctime;                         # Fileattribute auslesen.
         #########################################
         # Begriffe in allen Files suchen.
         #########################################
         $n1++;
         my $root = $tree->getDocumentElement;
         foreach my $component ($root->findnodes('component')) 
         {		    
            if ( $component->findvalue('type') eq $self->type) 
	    {
	    my $name = $component->findvalue('name');
	    my $str_name = $self->name;

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
print "Dateien verarbeitet: $n1\n\n";
}

###########################################################
#  HTML-Report erzeugen.
#
#  Parameter: Referenz auf ein AoH
###########################################################
sub hinventory_gen_html 
{
   croak "2 Argumente erwartet aber " . @_." erhalten." unless @_ == 2;

   my ($self, $recordset_ref) = @_;

   $| = 1;
   print "Content-type: text/html\n\n";

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
   croak "2 Argumente erwartet aber " . @_." erhalten." unless @_ == 2;

   my ($self, $recordset_ref) = @_;
  
   foreach my $rec ( @{ $recordset_ref }  ) 
   { 
      printf "%3d.) %15s   %40s   %30s\n",
      $rec->{'count'},
      $rec->{'filename'},
      $rec->{'name'},
      $rec->{'createtime'};
   }
}

__PACKAGE__->meta->make_immutable;
1;
