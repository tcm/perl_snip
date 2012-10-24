# Versionsbestimmung für Creo und Proe Wildfire.
#
# (jb) 10.10.2012

use strict;
use warnings;

#use Cwd;
#use File::Copy;
use File::Find;
use POSIX qw( strftime );
#use Devel::Size qw(size total_size);
#use File::Path;
#use File::Spec::Functions;
#use File::Basename;
#use File::Spec;
# use Data::Dumper;
use feature qw/switch/; 


my @final;
my @crit;

$crit[0] = '\.prt\.\d+$';
$crit[1] = '\.drw\.\d+$';


my %file_anz;             # assoziatives Array; 
                          # Schluessel = Dateiname; Wert = absolute anzahl der Dateien mit gleichem Anfang.

my %suff_max;             # assoziatives Array; 
                          # Schluessel = Dateiname; Wert = hoechste Endung
my %suff_max_minus_one;   # assoziatives Array; 
                          # Schluessel = Dateiname; Wert = zweithöchste Endung

my %version_pattern;      # assoziatives Array; 
                          # Schluessel = Dateiname; Wert = Versionsmuster (C=Creo, W=Wildfire, _=undef) 

my $num = 0;              # momentan höchste Endung.


my $key;
my $value;
my $dest_path = "d:\\archiv\\"; # Zielpfad zum verschieben der Dateien.
my $n;                          # Anzahl der Schlüssel im Hash.
my $timestamp;

$timestamp = strftime '%d/%m/%Y %H:%M:%S', localtime;
print "[$timestamp] PASS_1: Find candidates.\n";
find(\&rekur, "d:\\proe_creo\\627\\");
#find(\&rekur, "d:\\proe_creo\\627002");

 
###########################
# I. Kandidatenbestimmung.
###########################
$timestamp = strftime '%d/%m/%Y %H:%M:%S', localtime;
print "[$timestamp] PASS_2: Gernerate Hash(es).\n";
foreach my $matched_file (@final)
{
   $num = substr($matched_file, rindex($matched_file, ".")+1, );
   my $datei = substr($matched_file, 0, rindex($matched_file, "."));

   $file_anz{$datei}++; # Anzahl der Files pro Postfix bestimmen.
   
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

$n = keys %file_anz; print "\%file_anz: $n\n";
$n = keys %suff_max; print "\%suff_max: $n\n";
$n = keys %suff_max_minus_one; print "\%suff_max_minus_one: $n\n";
print "Clear Array: \@final\n\n";
@final = ();

# Größe des Hashes
#my $h_ref = \%file_anz;
#my $h_size = total_size($h_ref); 
#print "$h_size\n";


###############################
# II. Unnötige Keys löschen.
###############################
$timestamp = strftime '%d/%m/%Y %H:%M:%S', localtime;
print "[$timestamp] PASS_3: Delete from Hash(es) were COUNT < 2.\n";
while ( ($key,$value) = each %file_anz ) {
    #print "$key => $value\n";
    if ( $value < 2 ) 
    {
    delete $file_anz{$key};
    delete $suff_max{$key};
    delete $suff_max_minus_one{$key};
    }
}

$n = keys %file_anz; print "\%file_anz: $n\n";
$n = keys %suff_max; print "\%suff_max: $n\n";
$n = keys %suff_max_minus_one; print "\%suff_max_minus_one: $n\n";
print "Clear Hash: \%file_anz\n\n";
%file_anz = ();

###########################
# III. Versions-Pattern 
# erzeugen.
# evtl. Hashes anzeigen.
###########################
$timestamp = strftime '%d/%m/%Y %H:%M:%S', localtime;
print "[$timestamp] PASS_4: Generate Version-Pattern.\n";
# print "print: Shorter list COUNT\n";
# show_hash(\%file_anz);


print "Process: Shorter Hash MAX.\n";
construct_pattern(\%suff_max, \%version_pattern);

print "Process: Shorter Hash MAX_MINUS_ONE.\n";
construct_pattern(\%suff_max_minus_one, \%version_pattern);


###########################
# IV. Verschieben der  
# Kandidaten.
###########################
$timestamp = strftime '%d/%m/%Y %H:%M:%S', localtime;
print "[$timestamp] PASS_5: Move Files to Archiv.\n";
while ( ($key,$value) = each %version_pattern ) {
    
    if ($value eq "CW" ) { print "move $key.$suff_max{$key}\n" };
}


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
      push(@final, grep{/$rule/} $File::Find::name); 
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
       when (/2010370/) {  $sign = "C"; }
       when (/2006420/) {  $sign = "W"; }
       default          {  $sign = "_"; }
       }
       close $fh;

       # Wenn der Hash-Key schon existiert anhängen,
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


