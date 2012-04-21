#!/usr/bin/perl -w 
# Listing 
# aus Toolbox 5/2009
#
use strict;
use warnings;

use DEMO;
use DEMODEEPER;

# Objektorientierte Anwendung
my $demo = DEMO->new('Hallo Auenland!');
$demo->greetings();

my $deeper = DEMODEEPER->new('Grüße aus Isengart!');
$deeper->greetings();
$deeper->echo();

