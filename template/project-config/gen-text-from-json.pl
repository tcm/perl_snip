#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use JSON::PP;
use Template;
use Getopt::Std;
use Data::Dumper;
use File::Spec;

my $includedir;
my $hash_ref;
my $version = "0.2";
my %options;

##############################################################
# Option-Handling.
##############################################################
getopts( 'hvi:', \%options );

if ( defined $options{h} ) {
    print "-h: Help\n\n";
    print "-i: IncludePath (Path to Template-Files\n";
    print "-v: Version.\n";
    exit 0;
}

if ( defined $options{v} ) {
    print "version: $version\n";
    exit 0;
}

if ( defined $options{i} ) {
    $includedir = $options{i};
}
else {
    print "-i: Parameter IncludePath is mandatory!\n";
    exit 1;
}

my $includepath = File::Spec->catdir( $Bin, $includedir );
my $datafile = File::Spec->catdir( $Bin, $includedir, "main.json" );

##############################################################
# Template-Settings.
# Create new template object.
##############################################################
my $tt = Template->new(
    {
        INCLUDE_PATH => $includepath,
        INTERPOLATE  => 1,
    }
) || die "$Template::ERROR\n";

##############################################################
#  Read JSON-Datafile.
##############################################################
if ( -e $datafile ) {

    local $/;
    open( my $fh, '<', $datafile );
    my $json_text = <$fh>;
    $hash_ref = decode_json($json_text);
}
else {
    print "file error - main.json: not found\n";
}

$tt->process( "main.tt", $hash_ref ) || die $tt->error(), "\n";
