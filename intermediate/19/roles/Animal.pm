package Animal;
use Moose::Role;
use namespace::autoclean;

requires qw( sound default_color );


has 'name' => ( is => 'rw', required => 1 );
has 'color' => ( is => 'ro', writer => '_private_set_color', ,default => sub { shift->default_color } );

sub _private_set_color
{
  my ($self,$color) = @_;

  $self->color('$color');  
}


sub speak
{
   my $self = shift;
   print $self->name, " goes ", $self->sound, "\n";
}

1;
