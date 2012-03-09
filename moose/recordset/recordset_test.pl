#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use ArrayClass;
use HashClass;

my $array_obj = ArrayClass->new;
my $hash_obj = HashClass->new;


# Hash
$hash_obj->set_mapping('count', 1);
$hash_obj->set_mapping('name', "foo");
print Dumper $hash_obj;

#Array
my $array_obj = ArrayClass->new;
$array_obj->options(\$hash_obj);
print Dumper $hash_obj;
