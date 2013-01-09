#!/usr/bin/perl

use IO::Tee;
use autodie;

open my $log_fh, ">>", "testme.log";
open my $scalar_fh, ">>", \ my $string;

my $tee_fh = IO::Tee->new( $log_fh, $scalar_fh );
print $tee_fh "The quick brown fox jumps over the lazy dog!\n";
