#!/usr/bin/perl 

############################################################
#
#  Testen, ob alle Module verfügbar sind, die
#  nicht Standard sind.
#
############################################################
use strict;
use warnings;

use Test::More tests => 6;


use_ok( 'Path::Class' ); 
require_ok( 'Path::Class' );

use_ok( 'XML::LibXML' ); 
require_ok( 'XML::LibXML' );

use_ok( 'Template' ); 
require_ok( 'Template' );
