#!/usr/bin/perl

use strict;
use warnings;

use Module::CoreList;

print join "\n", Module::CoreList->find_modules(qr/.*/i, 5.014002);
