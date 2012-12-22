#!/usr/bin/perl

use strict;
use warnings;
use HTTP::SimpleLinkChecker qw(check_link);
use Data::Dumper;

my @good_links;
my @links_to_check =  ("www.ubuntu.com", "www.liniso.de", "www.perl.org");


#print check_link("www.liniso.de");

print Dumper @links_to_check;


@good_links = grep { 
  check_link($_); 
  ! $HTTP::SimpleLinkChecker::ERROR;
} @links_to_check;

print "\n";
print Dumper @good_links;
