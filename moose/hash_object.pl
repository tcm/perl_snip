#!/usr/bin/perl

use Data::Dumper;

package MyClass;
  use Moose;

  has 'mapping' => (
      traits  => ['Hash'],
      is      => 'rw',
      isa     => 'HashRef[Str]',
      default => sub { {} },
      handles => {
          exists_in_mapping => 'exists',
          ids_in_mapping    => 'keys',
          get_mapping       => 'get',
          set_mapping       => 'set',
          set_quantity      => [ set => 'quantity' ],
      },
  );

  my $obj = MyClass->new;
  $obj->set_quantity(10);      # quantity => 10
  $obj->set_mapping('foo', 4); # foo => 4
  $obj->set_mapping('bar', 5); # bar => 5
  $obj->set_mapping('baz', 6); # baz => 6



  # prints 5
  print $obj->get_mapping('bar')."\n" if $obj->exists_in_mapping('bar');
  print "\n"; 
  # prints 'quantity, foo, bar, baz'
  print join ', ', $obj->ids_in_mapping;
  print "\n";
