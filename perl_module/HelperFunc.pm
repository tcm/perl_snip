package HelperFunc;

use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

require  Exporter;

our $VERSION = 0.1;
our @ISA = qw(Exporter);
our @EXPORT = qw(atoi printme metnirp);
our @EXPORT_OK = qw(atoi printme metnirp);
our %EXPORT_TAGS = ( Functions => [ qw(atoi printme metnirp) ] );

sub atoi {
	my $t = 0;

	foreach my $d (split(//, shift())) {
	$t = $t * 10 + $d;
	}
	return $t;
}

sub printme { 
   print "$_[0]\n"; 
   print "$_[0]\n"; 
   print "$_[0]\n";
   return; 
}

sub metnirp {
  print reverse($_[0])."\n";
  print reverse($_[0])."\n";
  print reverse($_[0])."\n";
  return;
}

1;
