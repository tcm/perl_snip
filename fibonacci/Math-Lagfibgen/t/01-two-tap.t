use strict;
use warnings;

use Test::More tests => 3;
use Math::Lagfibgen;


# Check if the test was successful with the ok function. This test succeeds.
my $num1 = 1;
ok ($num1 == 1);

my $num2 = 2;
ok ($num2 == 2);


my $obj = Math::Lagfibgen->new({ j => 3, k => 7, mod => 10 });

my @expected  = (6, 1, 4, 4, 3, 9, 0, 4, 8, 1);
my @got = $obj->function2();
is_deeply(\@got, \@expected);


#my $obj2 = Math::Lagfibgen->new({ j => a, k => 7, mod => 10 });

