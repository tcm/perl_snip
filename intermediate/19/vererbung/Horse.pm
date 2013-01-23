package Horse;
use Moose;
use namespace::autoclean;

extends 'Animal';

has 'sound' => ( is => 'ro', default => 'schrrrr');

__PACKAGE__->meta->make_immutable;

1;
