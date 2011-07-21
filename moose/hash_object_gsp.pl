#!/usr/bin/perl

use Data::Dumper;

package Geldspeicher;
  use Moose;

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

  my $obj = Geldspeicher->new;
  $obj->set_mapping(0.1, 4); 
  $obj->set_mapping(0.2, 5); 
  $obj->set_mapping(0.5, 6); 



  # prints 5
  print $obj->get_mapping(0.1)."\n" if $obj->exists_in_mapping(0.1);
  print "\n"; 
  
  print join ', ', $obj->ids_in_mapping;
  print "\n";
