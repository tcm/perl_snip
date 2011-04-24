#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use Template;


my $tt = Template->new({
    INCLUDE_PATH => "$Bin/tt",
    INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

$tt->process('html.tt')
    || die $tt->error(), "\n";
