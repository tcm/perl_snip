#!/usr/bin/perl
#
# (jb) 12/2020

use strict;
use warnings;

use Data::Dumper;
use English qw( -no_match_vars );
use JSON::PP;
use Carp qw(croak);
use Scalar::Util qw(reftype);


my $filename = "./nbst.json";
my $hash_ref;

if (-e $filename) {

	local $/;
	open( my $fh, '<', $filename );
	my $json_text   = <$fh>;
	$hash_ref = decode_json( $json_text );
	#print Dumper $perl_scalar;

	&show_hash($hash_ref);
} else {
       #Do nothing.	
}

# For testing.
#$hash_ref->{4143} = 99;

&show_hash($hash_ref);

sub show_hash {
  my $hash_ref = shift;
  my $ref_type = reftype $hash_ref;

  croak "I expected as hash reference!"
    unless $ref_type eq ref {};

  while ( my ($key, $value) = each %$hash_ref ) {
	  print "$key => $value\n";
  }
}

exit 0;
