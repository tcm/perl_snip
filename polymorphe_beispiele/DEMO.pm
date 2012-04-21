# DEMO.pm ############################################
package DEMO;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(new greetings echo);


# Ich instantiiere Objekte
sub new 
{
  my $class = shift;
  my $data = { 'Parameter' => shift };
  bless($data, $class);
  return $data;
}

sub greetings
{
   # omnivore Routine
   use Scalar::Util;

   my $self = shift;

   # Objektaufruf oder nicht?
   if (defined(Scalar::Util::blessed ($self)))
   {
   print $$self{'Parameter'} . "\n";
   } 
   else
   {
   print $self . "\n";
   }

}


sub echo
{
   # omnivore Routine
   use Scalar::Util;

   my $self = shift;

   # Objektaufruf oder nicht?
   if (defined(Scalar::Util::blessed ($self)))
   {
   print $$self{'Parameter'} . "\n";
   } 
   else
   {
   print $self . "\n";
   }

}

1;
