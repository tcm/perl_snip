package Hinventory_Moose_AD;

use Moose;

has 'dest_file'      => (isa => 'Str', is => 'rw', default => 'computer.txt');
has 'blacklist_file' => (isa => 'Str', is => 'rw', default => 'blacklist.txt');
has 'xml_dir'        => (isa => 'Str', is => 'rw', default => 'q:/project_hinventory/xml');
has 'filepattern'    => (isa => 'Str', is => 'rw', default => '*.xml');

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

# Funktionen exportieren. 
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
require Exporter;
our $VERSION = 0.2;
our @ISA = qw(Exporter);
our @EXPORT = qw(gen_computer_txt_ad  gen_computer_txt_ad_diff);
our @EXPORT_OK = qw(gen_computer_txt_ad  gen_computer_txt_ad_diff);
our %EXPORT_TAGS = ( Functions => [ qw(gen_computer_txt_ad  gen_computer_txt_ad_diff) ] );

###########################################################
#  computer.txt erzeugen.
#
#  Wir lesen die Rechner aus dem AD aus.
#
#  Parameter:
#  1. Dateiname der Blacklist-Hosts (lesen).
#  2. Dateiname für Zieldatei (schreiben).
###########################################################
sub gen_computer_txt_ad 
{
   croak "1 Argumente erwartet aber " . @_." erhalten." unless @_ == 1;

   my $self = shift;

   my @hostlist;
   my $int_start_pos = 4;
   my $n = 0;


   ####################################################
   # Lookup-Hash aus blacklist-File generieren.
   ####################################################
   my %blacklist;
   open my $bl_fh, '<', $self->blacklist_file || die $self->blacklist_file," konnte nicht geoeffnet werden.\n"; # Die Datei enthält die Ausnahmen.

   while (<$bl_fh>) 
   {
      chomp;
      $blacklist{$_} = 'Do not scan.';
   }
   close ($bl_fh);


   ####################################################
   # Die Ausgabe für das Kommando 'dsquery' auslesen.
   ####################################################
   open my $readme_fh , "-|" ,"dsquery computer -limit 500" || die "Fehler bei fork: $!\n";
   while (<$readme_fh>) 
   {
      my ($cn_1,$cn_2,$cn_3,$cn_4) = split(/,/);                                       # Splitting in einzelne CN-Strings.
      my $int_len = length($cn_1);
      my $hostname = uc( substr($cn_1, $int_start_pos, ($int_len - $int_start_pos)) ); # Hostname aus CN_1 herauslösen.
      push (@hostlist, $hostname);
   }
   close($readme_fh);


   ####################################################
   # Ein Textfile erzeugen. Rechner aus der 
   # Blacklist werden weggelassen.
   ####################################################
   open my $ziel_fh, '>', $self->dest_file || die $self->dest_file," konnte nicht geoeffnet werden.\n"; # Die Datei, die für hinventory.vbs 
                                                                                                        # erzeugt werden muss.
   foreach my $host (sort @hostlist)                                                                    # Iterieren über das Array, 
                                                                                                        # um in das Textfile zu schreiben.
   {                                        		
      unless (exists ($blacklist{$host}) )  # Wenn kein Eintrag in der Blacklist existiert, ...
      {  
      $n++;	      
      print $ziel_fh "$host\n";             # ... Eintrag in das File schreiben.     				
      } 		
   }
   close($ziel_fh);

   print $self->dest_file," generated...\n";
   print "$n entries written...\n";
   
   my $backup_file = file($Bin,"computer_ref.txt");
   copy( $self->dest_file, $backup_file) or die "Copy failed: $!";
}

###########################################################
#  computer_diff.txt erzeugen.
#
#  Wir bilden einen Diff zum vorherigen Lauf.
#
# 
#  Parameter:
#  1. Pfad zu den XML-Dateien.
#  2. Suchmuster als BSD-Glob.
###########################################################
sub  gen_computer_txt_ad_diff
{
   croak "1 Argumente erwartet aber " . @_." erhalten." unless @_ == 1;

   my $self = shift;
   
   ###############################################
   # Lookup Hash aus bestehenden XML-Files bilden.
   ###############################################
   my $str_path = file($self->xml_dir, $self->filepattern);  
   my @files = bsd_glob "$str_path";
   my $anzahl_erfasst = @files;
   my %last_run;
   
   foreach my $file (@files) 
   {
	   # Alternativ mit Path:Class, wenn
	   # die Extension nicht gebraucht wird.
	   #my $o_file =  file( $file );
	   #print $o_file->basename."\n";  
   	   my ($base, $dir, $ext) = fileparse($file,".xml");
	   
           $last_run{ uc($base) } = 'Do not scan again.';
   }


   ####################################################
   #  Orginal computer.txt in Array einlesen.
   ####################################################
   my $quell_file = file($Bin,$self->dest_file);
   my $ziel_file = file($Bin,"computer_diff.txt");
   my $backup_file = file($Bin,"computer_bak.txt");
   my $n;
  
   open my $quell_fh, '<', $quell_file || die "$quell_file konnte nicht geoeffnet werden.\n";
   open my $ziel_fh, '>', $ziel_file || die "$ziel_file konnte nicht geoeffnet werden.\n";   
   while (<$quell_fh>) 
   {
      chomp;
      unless (exists ($last_run{ $_ }) )  # Wenn kein Eintrag in %lastrun existiert, ...
      {             	      
      print  $ziel_fh "$_\n";             # ... Eintrag in das File schreiben.      
      } 
      $n++;      
   }
   close ($quell_fh);
   close ($ziel_fh);

 
   print "Erfasste Rechner: $anzahl_erfasst/$n\n";
  


   ####################################################
   #  Orginal computer.txt sichern.
   #  computer_diff.txt wird neues File computer.txt.
   ####################################################
   copy( $quell_file, $backup_file) or die "Copy failed: $!";
   unlink  $quell_file;
   print "$quell_file gesichert nach $backup_file.\n";
   sleep(3);
   copy( $ziel_file, $quell_file) or die "Copy failed: $!";
   unlink  $ziel_file;
   print "$ziel_file kopiert nach $quell_file.\n";
}

__PACKAGE__->meta->make_immutable;
1;
