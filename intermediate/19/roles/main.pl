#!/usr/bin/perl

use Sheep;
use Cow;
use Horse;

my $object = Sheep->new( name => "Waldemar", color => 'grey'  );
$object->speak;

my $object2 = Cow->new( name => "Elsa", color => 'brown'  );
$object2->speak;

my $object3 = Horse->new( name => "Jolly", color => 'white'  );
$object3->speak;


my $object4 = Horse->new( color => 'white'  );
