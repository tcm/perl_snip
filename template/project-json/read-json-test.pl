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
my $version = "0.1";
my %options;

##############################################################
# Option-Handling.
##############################################################
getopts( 'hv', \%options );

if ( defined $options{h} ) {
    print "-h: Help\n\n";
    print "-v: Version.\n";
    exit 0;
}

if ( defined $options{v} ) {
    print "version: $version\n";
    exit 0;
}

my $includepath = File::Spec->catdir( $Bin );
my $datafile = File::Spec->catdir( $Bin, "main.json" );

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

my $array_ref = $hash_ref->{Vlans};

$tt->process('main.tt', { array => $array_ref }) || die $tt->error;
