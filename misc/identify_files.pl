# Versionsbestimmung für Creo und Proe Wildfire.
#
# (jb) 29.10.2012

use strict;
use warnings;

use File::Copy;
use File::Find;
use POSIX qw( strftime );
#use Devel::Size qw(size total_size);
use File::Path qw(make_path);
use Path::Class;
use Getopt::Std;
#use Data::Dumper;
use feature qw/switch/; 

my @candidates;           # Alle Dateien nach Suchmuster
my @final;                # Alle Dateien nach Suchmuster und COUNT >1 
my @crit;                 # Suchmuster 

$crit[0] = '\.prt\.\d+$'; # Suchmuster einzeln
$crit[1] = '\.drw\.\d+$';


my %file_anz;             # assoziatives Array; 
                          # Schluessel = Dateiname bis letzten Punkt; Wert = absolute Anzahl der Dateien mit gleichem Anfang.

my %suff_max;             # assoziatives Array; 
                          # Schluessel = Dateiname bis letzten Punkt; Wert = hoechste Endung
my %suff_max_minus_one;   # assoziatives Array; 
                          # Schluessel = Dateiname bis letzten Punkt; Wert = zweithöchste Endung

my %version_pattern;      # assoziatives Array; 
                          # Schluessel = Dateiname bis letzten Punkt; Wert = Versionsmuster (C=Creo, W=Wildfire, _=undef) 

my $num = 0;              # momentan höchste Endung.


my $key;
my $value;
my $source_path;          # Quellpfad zum verschieben der Dateien.
my $dest_path;            # Zielpfad zum verschieben der Dateien.
my $n;                    # Anzahl der Schlüssel im Hash.
my $timestamp;
my $version="0.9";
my %options;


getopts('i:o:v',\%options);

if(defined $options{v})
{	
print "\n---------------\n";
print "Version: $version\n";
print "---------------\n\n";
}

if(!defined $options{i})
{	
die "Quellverzeichniss (option -i) muss angegeben werden.\n";
}

if(!defined $options{o})
{	
die "Backupverzeichniss (option -o) muss angegeben werden.\n";
}


$source_path=file($options{i});
$dest_path=file($options{o});


#print "Quellpfad: $source_path\n";
#print "Zielpfad: $dest_path\n";

$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_1: Find candidates.\n";
find(\&rekur, $source_path);

 
###########################
# I. Anzahl der Dateien
# pro Prefix bestimmen.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_2: Gernerate Hash \%file_anz.\n";
foreach my $matched_file (@candidates)
{
   my $datei = substr($matched_file, 0, rindex($matched_file, "."));
   $file_anz{$datei}++; # Anzahl der Files pro Prefix erhöhen.
   #print "$matched_file\n";
}

#$n = keys %file_anz; print "\%file_anz: $n\n";

##################################
# II. Array nur mit den
# relevanten Kandidaten erzeugen.
##################################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_3: Create Array \@final were COUNT > 1.\n";

foreach my $matched_file (@candidates)
{
   #print "$matched_file\n"; 
   my $datei = substr($matched_file, 0, rindex($matched_file, "."));
   if ( $file_anz{$datei} > 1 ) { push ( @final, $matched_file); };  
}
@candidates = (); # Nicht benötige Datenstrukturen 
%file_anz = ();   # löschen.

$n = @final; print "$timestamp --  Anzahl: $n\n";

###############################
# IV. Hash mit der höchsten
# Endung pro Prefix erstellen.
#
# Hash mit der zweithöchsten
# Endung pro Prefix erstellen.
###############################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_4: Create Hashes \%suff_max \%suff_max_minus_one.\n";
foreach my $matched_file (@final)
{
   $num = substr($matched_file, rindex($matched_file, ".")+1, );
   my $datei = substr($matched_file, 0, rindex($matched_file, "."));
  
   ######################
   # Max-Bestimmung.
   # (Max-1)-Bestimmung. 
   ######################     
   if(exists($suff_max{$datei}) < $num)
   {
   $suff_max_minus_one{$datei} = $suff_max{$datei}; 	   
   $suff_max{$datei}=$num;
   }
}

###########################
# V. Version-Pattern 
# erzeugen.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_5: Generate Version-Pattern.\n";

print "$timestamp --  Process: Shorter Hash MAX.\n";
construct_pattern(\%suff_max, \%version_pattern);

$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  Process: Shorter Hash MAX_MINUS_ONE.\n";
construct_pattern(\%suff_max_minus_one, \%version_pattern);


###########################
# VI. Verschieben der  
# Kandidaten.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_6: Copy or Move Files to Archiv.\n\n";
while ( ($key,$value) = each %version_pattern ) 
{
   if ($value eq "CW" ) 
   {
   my $qfile =  file($key.".".$suff_max{$key});  # File-Objekt erzeugen (Filename + höchste Endung).
   my $qdir  = substr($qfile->dir,3, );          # Den Basis-Pfad extrahieren 
                                                 # und den Laufwerksbuchstaben abtrennen.

   my $dest_path_new = file ($dest_path, $qdir); # Den neuen Zielpfad zusammensetzen:
                                                 # Zielpfad + Verzeichnisteil des Quell-Files.

   make_path("$dest_path_new");
   print "Copy: ";  copy( $qfile, $dest_path_new) or die "File-Operation failed: $!";
   #print "Move: "; move( $qfile, $dest_path_new) or die "File-Operation failed: $!";
   print "$qfile\n";
   }

}
print "\n\nZiel: $dest_path\n";


##################
# Unterprogramm:
#
# Rekursive Suche
##################
sub rekur
{	
   foreach my $rule (@crit)
   {	     
      # Kandidaten zwischenspeichern.
      push(@candidates, grep{/$rule/} file($File::Find::name)); 
   }
}

exit 0;

###################
# Unterprogramm:
#
# Muster erzeugen.
###################
sub construct_pattern
{
   my ($qhash_ref, $zhash_ref) = @_;
   my $key;
   my $value;   
   my $file;
   my $sign;

   while ( ($key,$value) = each % {$qhash_ref} ) 
   {
       #print "$key => $value";
       #####################
       # Erste Zeile lesen.
       #####################
       $file =  $key.".".$value;
       #print "$file\n";

       open my $fh, '<', $file; 
       my $firstline = <$fh>; 

       ####################
       # Version prüfen.
       ####################
       given($firstline) 
       {
       when (/2010370/) {  $sign = "C"; } # Creo ?
       when (/2006420/) {  $sign = "W"; } # Wildfire ?
       default          {  $sign = "_"; } # Unbekannt ?
       }
       close $fh;

       # String erzeugen. Wenn der Hash-Key schon existiert anhängen,
       # ansonsten neu zuweisen.
       if( exists($zhash_ref->{$key})  ) 
       {
       my $temp = $zhash_ref->{$key};
       $zhash_ref->{$key} = $temp.$sign;    
       }
       else
       {
       $zhash_ref->{$key} = $sign;
       }
   }

}


###################
# Unterprogramm:
#
# Hash auflisten.
###################
sub show_hash
{

   my $hash_ref = shift;
   my $key;
   my $value;   

   while ( ($key,$value) = each % {$hash_ref} ) 
   {
       print "$key => $value\n";
   }

}


