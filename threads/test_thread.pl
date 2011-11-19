#!/usr/bin/perl
# This is compiled with threading support
#  
use strict;
use warnings;
use threads;
use threads::shared;
   
print "Starting main program\n";

# Threads erzeugen.    
my @threads;

for ( my $count = 1; $count <= 10; $count++) 
{
  my $t = threads->new(\&sub1, $count);
  push(@threads,$t);
}

# Threads abarbeiten.
foreach (@threads) 
{
   my $num = $_->join;
   print "done with $num\n";
}
print "End of main program\n";
exit 0;


# Thread-Routine.                                    
sub sub1 
{
    my $num = shift;
    print "started thread $num\n";
    sleep $num;
    print "done with thread $num\n";
    return $num;
}
