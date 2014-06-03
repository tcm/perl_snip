#!/usr/bin/perl


use File::Temp qw/ tempfile tempdir /;
use DDP;

%qhash1 = ();




$dir = tempdir( CLEANUP => 1 );

($fh, $filename) = tempfile( "file10.prt", DIR => $dir, SUFFIX => '.35');
$qhash1{$filename}="CW";
($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.33');
($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.7');
($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.5');
($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.2');
($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.1');


p %qhash1;


#($fh, $filename) = tempfile( $template, SUFFIX => '.dat');
#($fh, $filename) = tempfile( $template, TMPDIR => 1 );
#binmode( $fh, ":utf8" );
#$dir = tempdir( CLEANUP => 1 );
#($fh, $filename) = tempfile( DIR => $dir );
