#!/usr/bin/perl

use strict;
use warnings;

use Net::OpenSSH;
use Data::Dumper;

my $host = "192.168.0.100";

my $ssh = Net::OpenSSH->new($host, user => "user", password => "xxxxxxxxxxxxx");
$ssh->error and
   die "Couldn't establish SSH connection: ". $ssh->error;

my @ls = $ssh->capture("ls");
  $ssh->error and
    die "remote ls command failed: " . $ssh->error;

print Dumper @ls;
