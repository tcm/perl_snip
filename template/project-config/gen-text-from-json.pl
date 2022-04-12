#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use JSON::PP;
use Template;
use Getopt::Std;
use Data::Dumper;
use File::Spec;

my $projectdir;
my $hash_ref;
my $version = "0.2";
my %options;

##############################################################
# Option-Handling.
##############################################################
getopts( 'hvp:', \%options );

if ( defined $options{h} ) {
    print "-h: Help\n";
    print "-p: Projectdir (Path to Template-Files)\n";
    print "-v: Version.\n";
    exit 0;
}

if ( defined $options{v} ) {
    print "version: $version\n";
    exit 0;
}

if ( defined $options{p} ) {
    $projectdir = $options{p};
}
else {
    print "-p: Parameter Projecdir is mandatory!\n";
    exit 1;
}

my $projectpath = File::Spec->catdir( $Bin, $projectdir );
my $datafile = File::Spec->catdir( $Bin, $projectdir, "main.json" );

##############################################################
# Template-Settings.
# Create new template object.
##############################################################
my $tt = Template->new(
    {
        INCLUDE_PATH => $projectpath,
        INTERPOLATE  => 1,
    }
) or die "$Template::ERROR\n";

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

$tt->process( "main.tt", $hash_ref ) or die $tt->error(), "\n";
