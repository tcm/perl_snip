#!/usr/bin/perl -w 
# Listing 2
# aus Toolbox 5/2009
#
use strict;
use warnings;

package DEMO; # Wechsel des Namensraums

sub test 
{
 my $class = shift;
 my $para_2 = shift || "Leer";

 print 'Parameter 2. = "' . $para_2 . "\".\n";

 # Rückgabe einer als Objektinstanz von 
 # DEMO markierten Referenz.
 return (bless(\$para_2, $class));
}

package main;   # Zurück nach main

my $objekt = DEMO->test('Hallo Arda!');
print $objekt . "\n"; # liefert: DEMO=SCALAR(0xae520)
print"\n";

$objekt->test('Hallo Mittelerde!'); 
