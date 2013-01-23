package Sheep;
use Moose;
use namespace::autoclean;

with 'Animal';

sub default_color { 'white' };
sub sound { 'maaaeehhh' };

__PACKAGE__->meta->make_immutable;

1;
