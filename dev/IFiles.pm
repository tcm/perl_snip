package IFiles;

use strict;
use warnings;

use Data::Dumper;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
new 
count_candidate_files 
filter_candidate_files_by_count
get_max_file_postfix 
filter_hash_values_from_array 
testme);

# Konstruktor
sub new
{
  my $class = shift;  # Klassenname via Pfeilnotation
  my $self = shift;   # Referenz auf anonymen Hash

  foreach my $param(keys %$self)
  {
     print "$class: $param is set to: ".$self->{$param}; 
  }
  bless($self, $class);

  return($self);
}

# Anzahl der Files pro File-Prefix in Hash
# ablegen. Das File-Prefix geht vom
# Anfang bis zum Punkt vor der letzen Ziffer (ohne Punkt).
sub count_candidate_files
{
   my $self = shift;
   my $array_ref = shift; # Quelle: Array mit Dateinamen.
   my $hash_ref  = shift; # Ziel: Hash mit File-Prefix und Anzahl.
   
   foreach my $matched_file ( @{ $array_ref } )
   {
       my $file = substr($matched_file, 0, rindex($matched_file, "."));
       ${$hash_ref}{$file}++;           # Anzahl der Files pro Prefix erhöhen.
   }
   
}

# Filter erzeugt ein neues Array,
# dass nur Files mit Prefix enthält, 
# die öfter als einmal vorkommen.
sub filter_candidate_files_by_count
{
   my $self = shift;
   my $array_ref = shift;  # Quelle: Array mit Dateinamen.
   my $hash_ref  = shift;  # Quelle: Hash mit File-Prefix und Anzahl
   my $array2_ref = shift; # Ziel: Array mit Dateinamen. 
   
   foreach my $matched_file ( @{ $array_ref } )
   {
      my $file = substr($matched_file, 0, rindex($matched_file, ".")); # Prefix
      if ( ${$hash_ref}{$file} > 1 ) { push ( @{ $array2_ref }, $matched_file); }; # Anzahl groesser 1, dann speichern.
   }
   
}

# Ermittelt die Files mit dem 
# höchsten Postfix.
sub get_max_file_postfix
{
   my $self = shift;
   my $array_ref = shift;  # Quelle: Array mit Dateinamen.
   my $hash_ref  = shift;  # Ziel: Hash mit File-Prefix und maximalen Postfix
   my $num = 0;
   
   
   # Intialisierung des Hashes mit dem File-Prefix.
   foreach my $matched_file ( @{ $array_ref } )
   {
      my $file = substr($matched_file, 0, rindex($matched_file, ".")); # Prefix
      ${$hash_ref}{$file} = 0;
   }

   # Suche nach dem Maximum.
   foreach my $matched_file ( @{ $array_ref } )
   {
      $num = substr($matched_file, rindex($matched_file, ".") + 1, );    # Endung
      my $file = substr($matched_file, 0, rindex($matched_file, ".")); # Prefix

      if( ${$hash_ref}{$file}  < $num) # Max-Bestimmung.
      {
      ${$hash_ref}{$file}=$num;
      }
   }
}

# Speichert die Werte im Ziel-Array,
# die nicht im Filter-Hash enthalten sind.
sub filter_hash_values_from_array
{
   my $self = shift;
   my $array_ref = shift;    # Quelle: Array mit Dateinamen.
   my $hash_ref  = shift;    # Filter: Hash mit File-Prefix und maximalen Postfix.
   my $array2_ref  = shift;  # Ziel: Array mit Dateinamen. 
   my $num = 0;

   foreach my $matched_file ( @ { $array_ref } )
   {
      my $file = substr($matched_file, 0, rindex($matched_file, ".")); # Prefix
      $num = substr($matched_file, rindex($matched_file, ".")+1, );    # Endung

      unless ( ${$hash_ref}{$file} == $num )  # Nur wenn der Wert NICHT im Filter-Hash
      {                                       # enthalten ist, wird er im Ziel-Array gespeichert.
         push @{ $array2_ref }, $matched_file;
      } 
   }
   
} 

sub testme{
 print "blub\n";

}
1;
