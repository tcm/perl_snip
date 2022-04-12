#!/usr/bin/perl

use strict;
use warnings;

use FindBin '$Bin';
use Getopt::Std;
use Data::Dumper;
use File::Spec;
use File::Copy;

my $projectdir;
my $version = "0.2";
my %options;

##############################################################
# Option-Handling.
##############################################################
getopts( 'hvp:', \%options );

if ( defined $options{h} ) {
    print "-h: Help\n";
    print "-p: Projectdir\n";
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
    print "-p: Parameter Projectdir is mandatory!\n";
    exit 1;
}
##############################################################
# Construct filepathes. $Bin is the directory of the script.
##############################################################
my $projectpath = File::Spec->catdir( $Bin, $projectdir );
my $sourcepath = File::Spec->catdir( $Bin, "template", "*");
my @sourcefiles = glob $sourcepath;

###############################################################
# When Projectdir already exists, do nothing.
# Otherwise create dir and copy template files.
###############################################################
if (-d $projectpath ) {
	print "Projectdir already exists!\n";
	exit 1;
} else {
	mkdir($projectpath, 0755) or die "Mkdir failed $!";
	foreach my $file ( @sourcefiles ) {
   		copy( $file, $projectpath) or die "Copy failed: $!";
	}
}
