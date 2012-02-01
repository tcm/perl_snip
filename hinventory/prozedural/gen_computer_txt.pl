############################################################
#  Erzeugt das File 'computer.txt' für 'hinventory.vbs'
#  aus dem Active-Directory.
#
# (jb) 2011
############################################################

use strict;
use warnings;

use Data::Dumper;
use Getopt::Std;

use Path::Class;
use File::Basename;
use File::Copy;
use File::Glob ':glob';
use FindBin '$Bin';
use Carp 'croak';


my $backlist_datei = "blacklist.txt";
my $ziel_datei = "computer.txt";
my %opts;

getopts('hsd', \%opts);


if (defined $opts{h}) 
{
print "gen_computer_txt.pl [-c] [-d] [-h]\n\n";
print "-h Hilfe\n";
print "-s Referenz-Datei erzeugen.\n";
print "-d Diff zur Referenz-Datei erzeugen.\n";
exit 0;
}

#gen_computer_txt_ad( $backlist_datei,  $ziel_datei );


gen_computer_txt_ad_diff("q:/project_hinventory/xml", "*.xml");

exit 0;


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
   croak "2 Argumente erwartet aber " . @_." erhalten."
      unless @_ == 2;

   my ($bl_datei, $ziel_datei) = @_;

   my @hostlist;
   my $int_start_pos = 4;
   my $n = 0;


   ####################################################
   # Lookup-Hash aus blacklist-File generieren.
   ####################################################
   my %blacklist;
   open my $bl_fh, '<', $bl_datei || die "$bl_datei konnte nicht geoeffnet werden.\n"; # Die Datei enthält die Ausnahmen.

   while (<$bl_fh>) 
   {
      chomp;
      $blacklist{$_} = 'Do not scan.';
   }
   close ($bl_fh);


   ####################################################
   # Die Ausgabe für das Kommando 'dsquery' auslesen.
   ####################################################
   open my $readme_fh , "dsquery computer -limit 500 |" || die "Fehler bei fork: $!\n";
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
   open my $ziel_fh, '>', $ziel_datei || die "$ziel_datei konnte nicht geoeffnet werden.\n"; # Die Datei, die für hinventory.vbs erzeugt werden muss.
   foreach my $host (sort @hostlist)                                                         # Iterieren über das Array, um in das Textfile zu schreiben.
   {                                        		
      unless (exists ($blacklist{$host}) )  # Wenn kein Eintrag in der Blacklist existiert, ...
      {  
      $n++;	      
      print $ziel_fh "$host\n";             # ... Eintrag in das File schreiben.     				
      } 		
   }
   close($ziel_fh);

   print "$ziel_datei generated...\n";
   print "$n entries written...\n";
   
   my $backup_file = file($Bin,"computer_ref.txt");
   copy( $ziel_datei, $backup_file) or die "Copy failed: $!";
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
   croak "2 Argumente erwartet aber " . @_." erhalten."
   unless @_ == 2;

   my ($xml_dir, $str_filepattern) = @_;

   
   ###############################################
   # Lookup Hash aus bestehenden XML-Files bilden.
   ###############################################
   my $str_path = file($xml_dir, $str_filepattern);  
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
   my $quell_file = file($Bin,"computer.txt");
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
   sleep(3);
   copy( $ziel_file, $quell_file) or die "Copy failed: $!";
   unlink  $ziel_file;
}
