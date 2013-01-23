#!/usr/bin/perl

use Horse;
use v5.10;

my $object = Horse->new( name => "Jolly Jumper" );
say $object->speak;
