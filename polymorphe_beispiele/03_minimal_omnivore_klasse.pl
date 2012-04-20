#!/usr/bin/perl -w 
# Listing 3
# aus Toolbox 5/2009
#
use strict;
use warnings;



# Objektorientierte Anwendung
my $demo = DEMO->new('Hallo Auenland!');
$demo->greetings();

# Prozedurale Anwendung
DEMO::greetings('Willkommen in Mordor!');





package DEMO; # Wechsel des Namensraums

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
