#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use Getopt::Std;
use Data::Dumper;
use File::Spec;
use File::Copy;

my $projectname;
my $version = "0.1";
my %options;

##############################################################
# Option-Handling.
##############################################################
getopts( 'hvp:', \%options );

if ( defined $options{h} ) {
    print "-h: Help\n\n";
    print "-p: Projectname\n";
    print "-v: Version.\n";
    exit 0;
}

if ( defined $options{v} ) {
    print "version: $version\n";
    exit 0;
}

if ( defined $options{p} ) {
    $projectname = $options{p};
}
else {
    print "-p: Parameter Projectname is mandatory!\n";
    exit 1;
}

my $projectpath = File::Spec->catdir( $Bin, $projectname );
my $sourcepath = File::Spec->catdir( $Bin, "template", "*");
my @sourcefiles = glob $sourcepath;

#print $projectpath."\n";
#print $sourcepath."\n";
#print Dumper @sourcefiles;

#exit 0;

mkdir($projectpath, 0755) unless(-d $projectpath );

foreach my $file ( @sourcefiles ) {
   copy( $file, $projectpath) or die "Copy failed: $!";
}
