#!/usr/bin/perl

use Sheep;
use Cow;
use Horse;

# Komischerweise kann man bei 'New'
# das ro-Attribut 'color' beschreiben.
my $object = Sheep->new( name => "Waldemar", color => 'grey'  );
$object->speak;

my $object2 = Cow->new( name => "Elsa", color => 'brown'  );
$object2->speak;

my $object3 = Horse->new( name => "Jolly", color => 'white'  );
$object3->speak;

# Beschreibt man es nicht, wird die 'default_color' genommen.
# Danach lässt sich die Farbe, eben nicht mehr ändern.
# Nur noch per private-Methode.
my $object4 = Horse->new( name => "Fury" );
print $object4->color."\n";
# $object4->color('green'); # WRONG

$object4->_private_set_color('lila');
print $object4->color."\n";

