#!/usr/bin/perl

use Data::Dumper;

package Cell;
  use Moose;

  has 'wtk' => (isa => 'Num', is => 'rw', required => 1);
  has 'anz' => (isa => 'Int', is => 'rw', required => 1);

  sub clear {
      my $self = shift;
      $self->wtk(0);
      $self->anz(0);
  }

#package Point3D;
#  use Moose;

#  extends 'Point';

#  has 'z' => (isa => 'Int', is => 'rw', required => 1);

#  after 'clear' => sub {
#      my $self = shift;
#      $self->z(0);
#  };

  package main;

  # hash or hashrefs are ok for the constructor
  my $gsp = Cell->new(wtk => 0.5, anz => 7);

  

print Dumper $gsp;
