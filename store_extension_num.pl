#!/usr/bin/perl
#
# (bac) 12/2020
#
# Parse output of Mitel-command: ip_extension_info
# Store Extension status persistent to JSON-File.
use strict;
use warnings;

use Getopt::Std;
use Data::Dumper;
use English qw( -no_match_vars );
use JSON::PP;
use Carp qw(croak);
use Scalar::Util qw(reftype);
use File::Copy;
use POSIX qw( strftime );
use FindBin '$Bin';

my $version = "0.5";
my %options;
my $datafile = "$Bin/nbst.json";
my $hash_ref;
my $timestamp = strftime '%d%m%Y%H%M%S', localtime;


getopts( 'fhv', \%options );

if ( defined $options{h} ) {
    print "store_extension_num [STDIN] -f <datafile> [-h][-v]\n";
    print "-v: version.\n";
    print "-h: help\n\n";

    print "Examples:\nip_extension_info | store_extension_num.pl\ncat textfile | store_extension_num.pl\n\n";

    exit 0;
}

if ( defined $options{v} ) {
    print "version: $version\n";
}

if ( defined $options{f} ) {
    $datafile=$options{f};
}

# If a JSON-File exists, read it
# and store values in existing hash.
 if (-e $datafile) {
          
          local $/;
          open( my $fh, '<', $datafile );
          my $json_text   = <$fh>; 
          $hash_ref = decode_json( $json_text );
	  #&show_hash($hash_ref);
  } else {
         #Do nothing.     
 }     

# Read from <STDIN>
while (<>) {
    
    # Split when there are one or more spaces.
    my @column = split (/\s+/, $ARG);

    # column[0] = extension number
    # column[2] = ipv4 address or 'Not'
    #
    # Extension not registered? Don't increment counter.
    if ( $column[2] =~ /Not/ ) { 
      $hash_ref->{$column[0]} += 0;
    }
    else
    {
       # Add 1 to counter.
       $hash_ref->{$column[0]} += 1;
    }
}

# Write Hash to JSON-File.
my $j = JSON::PP->new->utf8->pretty(1);
my $output = $j->encode({ %$hash_ref });

my $tempfile = $datafile."-temp";
my $backupfile = $datafile."_$timestamp";

open my $fh_temp, ">", $tempfile or die "Can't open $tempfile: $!";
print $fh_temp $output;
close $fh_temp;

# Make Backup-File
if (-e $datafile) {
   copy($datafile,$backupfile) or die "Copy failed: $!";;
}

# Rotate old and new file.
if (-e $tempfile ) {
   copy($tempfile, $datafile) or die "Copy failed: $!";;
}
unlink($tempfile) or die "Unlink failed: $!";;

exit 0;

###############
# Functions
###############
sub show_hash {
   my $hash_ref = shift;
   my $ref_type = reftype $hash_ref;

   croak "I expected as hash reference!"
     unless $ref_type eq ref {};

   while ( my ($key, $value) = each %$hash_ref ) {
           print "$key => $value\n";
   }
   return 0;
 }
