#!/usr/bin/perl

# Objekte mit Moose und den eingebauten
# Goodies für perl-Datentypen. :-)
#
# (jb) 2011


use Data::Dumper;

package Speicher;
  use Moose;

# Vertige Klasse fuer den Datentyp 'Hash'.
  has 'mapping' => (
      traits  => ['Hash'],
      is      => 'rw',
      isa     => 'HashRef[Num]', # Num bezieht sich auf den Wert, und nicht auf den Schlüssel.
      default => sub { {} },
      handles => {
          exists_in_mapping => 'exists',
          ids_in_mapping    => 'keys',
          get_mapping       => 'get',
          set_mapping       => 'set',
      },
  );

# Rein.
sub fuellen {
      my ( $self, $id, $menge ) = @_;

      if ( $self->exists_in_mapping($id) ) { 
      		$self->set_mapping( $id, $self->get_mapping($id) + $menge );
      } else {
		print "Id:$id nicht vorhanden.\n";
      }
}

# Raus.
sub leeren {
	my ( $self, $id, $menge ) = @_;
       
	if ( $self->exists_in_mapping($id) ) { 
		$self->set_mapping( $id, $self->get_mapping($id) - $menge );
	} else {  
		print "Id:$id nicht vorhanden.\n";
	}
}


# Klasse kann nicht mehr veraendert werden.
__PACKAGE__->meta->make_immutable;


  my $obj = Speicher->new;
  $obj->set_mapping(0.1, 5); 
  $obj->set_mapping(0.2, 6); 
  $obj->set_mapping(0.5, 7); 



  # prints 5
  print $obj->get_mapping(0.1)."\n" if $obj->exists_in_mapping(0.1);
  print "\n";

  # prints 8
  $obj->fuellen(0.1, 3); 
  print $obj->get_mapping(0.1)."\n" if $obj->exists_in_mapping(0.1);
  print "\n"; 
  
 # prints 1
  $obj->leeren(0.1, 7);
  print $obj->get_mapping(0.1)."\n" if $obj->exists_in_mapping(0.1);
  print "\n";
 
  print join ', ', $obj->ids_in_mapping;

  print "\n";
