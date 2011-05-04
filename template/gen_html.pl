#!/usr/bin/perl

use strict;
use FindBin '$Bin';
use Template;

my   $vars = {
           
                 url =>"ab", 
                 title=>"cd"
            
        
      };

my $tt = Template->new({
    INCLUDE_PATH => "$Bin/tt",
    INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

$tt->process('html.tt',$vars)
    || die $tt->error(), "\n";
