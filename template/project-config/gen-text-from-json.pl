#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use JSON::PP;
use Template;
use Getopt::Std;
use Data::Dumper;
use File::Spec;

my $parameter_a;
my $projectdir;
my $hash_ref;
my $version = "0.3";
my %options;

##############################################################
# Option-Handling.
##############################################################
getopts( 'hva:p:', \%options );

if ( defined $options{h} ) {
    print "-h: Help\n";
    print "-v: Version\n";
    print "-a: Here you can declare an external value.\n";
    print "    e.g: -a foo123. This value can also be used in the template file.\n";
    print "-p: Projectdir (Path to Template-Files)\n";
    exit 0;
}

if ( defined $options{v} ) {
    print "version: $version\n";
    exit 0;
}

if ( defined $options{a} ) {
    $parameter_a = $options{a};
}
else {
    print "-a: Parameter_a has no value.\n";
    exit 1;
}

if ( defined $options{p} ) {
    $projectdir = $options{p};
}
else {
    print "-p: Parameter Projecdir is mandatory!\n";
    exit 1;
}

#############################################################
# Construct different pathes.
# $Bin is the actual scriptdir.
#############################################################
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
#  Read JSON-Datafile and store values in a hash.
##############################################################
if ( -e $datafile ) {

    local $/;
    open( my $fh, '<', $datafile );
    my $json_text = <$fh>;
    $hash_ref = decode_json($json_text);
}
else {
    print "$projectdir:\n";
    print "file error - main.json: not found\n";
}

##############################################################
# If defined, add external value also to hash.
##############################################################
if ( defined $options{a} ) {
    $hash_ref->{"parameter_a"} = $parameter_a;
}

$tt->process( "main.tt", $hash_ref ) or die $tt->error(), "\n";
