#!/usr/bin/perl

use strict;
use warnings;
chdir;

while(1)
{
   print "> ";
   chomp ( my $regex = <STDIN> );
 
   last unless ( defined $regex && length $regex );


   print 
     map { "    $_\n" }
     grep { eval { /$regex/ } }
     glob ( ".* *");
}
