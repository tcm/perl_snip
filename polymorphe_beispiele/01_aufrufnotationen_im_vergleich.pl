#!/usr/bin/perl -w
# Listing 1 
# aus Toolbox 5/2009
#
use strict;
use warnings;

package DEMO; # Wechsel des Namnensraums

sub test 
{
 my $para_1 = shift;
 my $para_2 = shift || "Leer";

 print 'Parameter 1. = "' . $para_1 . "\".\n";
 print 'Parameter 2. = "' . $para_2 . "\".\n";
 print "\n";

}

package main;   # Zurück nach main

DEMO::test('Hallo Welt!'); # Pipsnotation
DEMO->test('Hallo Arda!'); # Pfeilnotation
