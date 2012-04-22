#!/usr/bin/perl -w 
# Listing 10 
# aus Toolbox 5/2009
#
use strict;
use warnings;
use feature ':5.10';

my $object = Toolbox->new({ HEFT => 5,
                            SEITEN => 100,
                            PREIS => 11.90,
                            TITEL => 'Das Werkzeug...',
                            LEVEL => 'Wizard'});


say $object;


package Toolbox;

# Constructor
sub new 
{
  my $class = shift; # Klassenname via Pfeilnotation
  my $self = shift; # Referenz auf anonymen Hash

  foreach my $param(keys %$self)
  {
     # Syntaktisches Salz
     print "$param is set to: " . $$self{$param} . "\n";

     # Syntaktischer Zucker
     say "$param is set to: " . $self->{$param};
  } 

  bless($self, $class);
  # Markierung der Referenz mit dem Klassennamen
  return($self);
}
