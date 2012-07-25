# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Mytest.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 4;
BEGIN { use_ok('Mytest') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
is(&Mytest::is_even(0), 1);
is(&Mytest::is_even(1), 0);
is(&Mytest::is_even(2), 1)
