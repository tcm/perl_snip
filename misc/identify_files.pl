# Versionsbestimmung f�r Creo und Proe Wildfire.
#
# (jb) 28.11.2012

#perl2exe_include "Path/Class/Entity.pm";

use strict;
use warnings;

use File::Copy;
use File::Find;
use POSIX qw( strftime );
use File::Path qw(make_path);
use Path::Class;
use Getopt::Std;
use feature qw/switch/; 
#use Data::Dumper;

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
                          # Schluessel = Dateiname bis letzten Punkt; Wert = zweith�chste Endung

my %version_pattern;      # assoziatives Array; 
                          # Schluessel = Dateiname bis letzten Punkt; Wert = Versionsmuster (C=Creo, W=Wildfire, _=undef) 

my $num = 0;              # momentan h�chste Endung.


my $key;
my $value;
my $source_path;          # Quellpfad zum verschieben der Dateien.
my $dest_path;            # Zielpfad zum verschieben der Dateien.
my $n;                    # Anzahl der Schl�ssel im Hash.
my $timestamp;
my $version="0.93.1";
my %options;


getopts('i:o:vdzh',\%options);

if(defined $options{h})
{	
print "identify_files.exe  -i <Quellpfad> -o <Purgepfad> [-v][-d][-z][-h]\n";
print "-v: Versionsnummer.\n";
print "-i Zu durchsuchende Verzeichnisse.\n";
print "-o: Verzeichnisse zu dem die Files verschoben werden.\n";
print "-d: Dryrun zeigt nur an was passiert.\n";
print "-z: Optimierungen einschalten.\n";
print "-h: Hilfe.\n";
exit 0;
}


if(defined $options{v})
{	
print "\n---------------\n";
print "Version: $version\n";
print "---------------\n\n";
}

if(!defined $options{i})
{	
die "Input-Path (option -i) muss angegeben werden. Hilfe mit -h\n";
}

if(!defined $options{o})
{	
die "Output-Path (option -o) muss angegeben werden. Hilfe mit -h\n";
}


$source_path=file($options{i});
$dest_path=file($options{o});


print "Input-Path: $source_path\n";
print "Output-Path: $dest_path\n";

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
   $file_anz{$datei}++; # Anzahl der Files pro Prefix erh�hen.
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

# show_hash(\%file_anz);
# print "\n\n";
# foreach my $row (@final)
# {
#    print "$row\n";
# }


@candidates = (); # Nicht ben�tige Datenstrukturen 
%file_anz = ();   # l�schen.

$n = @final; print "$timestamp --  Count \@final: $n\n";



###############################
# IV. Hash mit der h�chsten
# Endung pro Prefix erstellen.
#
# Hash mit der zweith�chsten
# Endung pro Prefix erstellen.
###############################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_4: Create Hashes \%suff_max and \%suff_max_minus_one.\n";

foreach my $matched_file (@final)
{
   $num = substr($matched_file, rindex($matched_file, ".")+1, );
   my $datei = substr($matched_file, 0, rindex($matched_file, "."));
  
   ######################
   # Max-Bestimmung.
   ######################     
   if(exists($suff_max{$datei}) < $num)
   {   
   $suff_max{$datei}=$num;

   # print "---------------------\n";
   # print "Datei: $datei    Num: $num\n";
   # print "\n\nMAX:\n";
   # show_hash(\%suff_max);
   # my $taste = <STDIN>;
   }
}

foreach my $matched_file (@final)
{
   $num = substr($matched_file, rindex($matched_file, ".")+1, );
   my $datei = substr($matched_file, 0, rindex($matched_file, "."));
  
   ######################
   # (Max-1)-Bestimmung. 
   ######################
   if ($suff_max{$datei} != $num )
   {
   if(exists($suff_max_minus_one{$datei}) < $num)
   {   
   $suff_max_minus_one{$datei}=$num;

   # print "---------------------\n";
   # print "\n\nMAX_MINUS_ONE:\n";
   # show_hash(\%suff_max_minus_one);
   # my $taste = <STDIN>;
   }
   }
}
#print "\n\n";
#show_hash(\%suff_max);
#print "\n\n";
#show_hash(\%suff_max_minus_one);

###########################
# V. Version-Pattern 
# erzeugen.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  PASS_5: Generate Version-Pattern.\n";

print "$timestamp --  Process: Shorter Hash MAX.\n";
$n = keys %suff_max; print "$timestamp --  Count \%suff_max: $n\n";
construct_pattern(\%suff_max, \%version_pattern);

#############################
# Optimierung:
# Wir gehen die Liste mit
# den dem ersten Pattern durch.
# Im Prinzip m�ssen wir
# ja nur die Files betrachten,
# die in der h�chsten Version
# mit Creo gezeichnet wurden.
# Alle anderen l�schen wir
# aus den Hashes.
#############################
#print "\n\nVorher:\n";
#show_hash(\%suff_max);
#print "\n";
#show_hash(\%version_pattern);

if(defined $options{z})
{
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp --  Optimize: Shrink  Hashes MAX and MAX_MINUS_ONE.\n";
while ( ($key,$value) = each %version_pattern ) 
{
    if ($value ne "C" ) 
    {  
    delete $suff_max{$key}; 
    delete $suff_max_minus_one{$key}
    }
}
$n = keys %suff_max_minus_one; print "$timestamp --  Count \%suff_max_minus_one: $n\n";
}
#print "\n\nNachher:\n";
#show_hash(\%suff_max);
#show_hash(\%suff_max_minus_one);


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
   my $qfile =  file($key.".".$suff_max{$key});  # File-Objekt erzeugen (Filename + h�chste Endung).
   my $qdir  = substr($qfile->dir,3, );          # Den Basis-Pfad extrahieren 
                                                 # und den Laufwerksbuchstaben abtrennen.

   my $dest_path_new = file ($dest_path, $qdir); # Den neuen Zielpfad zusammensetzen:
                                                 # Zielpfad + Verzeichnisteil des Quell-Files.

   make_path("$dest_path_new");
   if(defined $options{d})
   {
   print "Dryrun: "; 
   print "$qfile\n";
   }
   else
   {
   #print "Copy: ";  copy( $qfile, $dest_path_new) or die "File-Operation failed: $!";
   print "Move: "; move( $qfile, $dest_path_new) or die "File-Operation failed: $!";
   print "$qfile\n";
   }
   }

}
print "\n\nDestination: $dest_path\n";
exit 0;

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
return;
}


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
       # Version pr�fen.
       ####################
       given($firstline) 
       {
       when (/2010370/) {  $sign = "C"; } # Creo ?
       when (/2006420/) {  $sign = "W"; } # Wildfire ?
       default          {  $sign = "_"; } # Unbekannt ?
       }
       close $fh;

       # String erzeugen. Wenn der Hash-Key schon existiert anh�ngen,
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
return;
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
return;
}
