#!/usr/bin/perl
# Versionsbestimmung für Creo und Proe Wildfire.
#
# (jb) 03.06.2014


use strict;
use warnings;

use File::Copy;
use File::Find;
use POSIX qw( strftime );
use File::Path qw(make_path);
use Getopt::Std;

use DDP;
use IFiles;


my @candidates; # Alle Dateien nach Suchmuster
my @final;      # Alle Dateien nach Suchmuster und COUNT > 1
my @final2;     # Alle Dateien nach Suchmuster und ohne Dateien mit der höchsten Endung.

my @crit;                 # Die Suchmuster
$crit[0] = '\.prt\.\d+$'; # Suchmuster einzeln
$crit[1] = '\.drw\.\d+$';


my %file_anz;           # assoziatives Array.
                        # Schluessel = Dateiname bis letzten Punkt; Wert = absolute Anzahl der Dateien mit gleichem Anfang.

my %suff_max;           # assoziatives Array.
                        # Schluessel = Dateiname bis letzten Punkt; Wert = hoechste Endung.

my %suff_max_minus_one; # assoziatives Array.
                        # Schluessel = Dateiname bis letzten Punkt; Wert = zweithöchste Endung.

my %version_pattern;    # assoziatives Array.
                        # Schluessel = Dateiname bis letzten Punkt; Wert = Versionsmuster (C=Creo, W=Wildfire, _=undef)


my %files_to_move;      # assoziative Array.  
                        # Schluessel = Quell-File; Wert = Zielpfad

my $num = 0;            # momentan höchste Endung.


my $key;
my $value;
my $source_path;        # Quellpfad zum verschieben der Dateien.
my $dest_path;          # Zielpfad zum verschieben der Dateien.
my $n;                  # Anzahl der Schlüssel im Hash.
my $timestamp;
my $version="0.98";
my %options;

getopts('i:o:vdzh',\%options);

if(defined $options{h})
{	
print "identify_files.exe -i <Quellpfad> -o <Purgepfad> [-v][-d][-z][-h]\n";
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


$source_path=$options{i};
$dest_path=$options{o};


print "Input-Path: $source_path\n";
print "Output-Path: $dest_path\n\n";


##########################
# 1. Kandidaten
#    nach Suchmuster 
#    finden.
##########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- PASS_1: Find candidates.\n";

find(\&rekur, $source_path);
 
###########################
# 2. Anzahl der Dateien
# pro Prefix bestimmen.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- PASS_2: Gernerate Hash \%file_anz.\n";

my $obj_files = IFiles->new();
$obj_files->count_candidate_files(\@candidates,\%file_anz);

##################################
# 3. Array nur mit den
# relevanten Kandidaten erzeugen.
##################################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- PASS_3: Create Array \@final were COUNT > 1.\n";

$obj_files->filter_candidate_files_by_count(\@candidates,\%file_anz,\@final);
@candidates = (); # Nicht benötige Datenstrukturen
%file_anz = ();   # wieder freigeben.
$n = @final; print "$timestamp -- Count \@final: $n\n";

###############################
# 4. Maxmimum-Bestimmung.
# Hash mit der höchsten
# Endung pro Prefix erstellen.
#
# Ein neues Array erzeugen,
# das die Dateien mit höchsten
# Endung nicht mehr enthält.
#
# Erneute Maximum-Bestimmung.
# Hash mit der zweithöchsten
# Endung pro Prefix erstellen.
###############################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- PASS_4: Create Hashes \%suff_max and \%suff_max_minus_one.\n";

$obj_files->get_max_file_postfix(\@final,\%suff_max);
$obj_files->filter_hash_values_from_array(\@final,\%suff_max,\@final2);
$obj_files->get_max_file_postfix(\@final2,\%suff_max_minus_one);

$n = @final2; print "$timestamp -- Count \@final2: $n\n";
###########################
# 5. Version-Pattern
# erzeugen.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- PASS_5: Generate Version-Pattern.\n";

print "$timestamp -- Process: Shorter Hash MAX.\n";
$n = keys %suff_max; print "$timestamp -- Count \%suff_max: $n\n";
$obj_files->construct_pattern(\%suff_max, \%version_pattern);
#p %version_pattern;

#############################
# Optimierung:
# Wir gehen die Liste mit
# den dem ersten Pattern durch.
# Im Prinzip müssen wir
# ja nur die Files betrachten,
# die in der höchsten Version
# mit Creo gezeichnet wurden.
# Alle anderen löschen wir
# aus den Hashes.
#############################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- Optimize: Shrink Hashes MAX and MAX_MINUS_ONE.\n";
$obj_files->optimize_hash(\%version_pattern, \%suff_max, \%suff_max_minus_one);
$n = keys %suff_max_minus_one; print "$timestamp -- Count \%suff_max_minus_one: $n\n";


$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- Process: Shorter Hash MAX_MINUS_ONE.\n";
$obj_files->construct_pattern(\%suff_max_minus_one, \%version_pattern);


###########################
# VI. Verschieben der
# Kandidaten.
###########################
$timestamp = strftime '%d-%m-%Y %H:%M:%S', localtime;
print "$timestamp -- PASS_6: Copy or Move Files to Archiv.\n\n";
$obj_files->construct_file_names(\%version_pattern, \%suff_max, $dest_path, \%files_to_move);

while ( ($key,$value) = each %files_to_move )
{

   make_path("$value");
   if(defined $options{d})
   {
   print "Dryrun: ";
   print "$key -> $value\n";
   }
   else
   {
   print "Copy: "; copy( $key, $value) or die "File-Operation failed: $!";
   #print "Move: "; move( $key, $value) or die "File-Operation failed: $!";
   print "$key -> $value\n";
   }
   
}

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
      #push(@candidates, grep{/$rule/} file($File::Find::name));
      push(@candidates, grep{/$rule/} $File::Find::name);
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

