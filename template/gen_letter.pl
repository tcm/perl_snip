#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use Template;


my $tt = Template->new({
    INCLUDE_PATH => "$Bin/tt",
    INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

my $vars = {
    name     => 'Count Edward van Halen',
    debt     => '3 riffs and a solo',
    deadline => 'the next chorus',
};

$tt->process('letter.tt', $vars)
    || die $tt->error(), "\n";
