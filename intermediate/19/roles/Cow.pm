package Cow;
use Moose;
use namespace::autoclean;

with 'Animal';

sub default_color { 'black and white' };
sub sound { 'muuuuhh' };

after 'speak' => sub { print "[....weil sie ist eine Kuh.]\n"; };


__PACKAGE__->meta->make_immutable;

1;
