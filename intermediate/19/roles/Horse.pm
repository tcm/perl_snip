package Horse;
use Moose;
use namespace::autoclean;

with 'Animal';

sub default_color { 'white and green' };
sub sound { 'brrrrrrr' };


__PACKAGE__->meta->make_immutable;

1;
