#!/usr/bin/perl

use warnings;
use strict;

        while (<>) 
        {                   # take one input line at a time
	    chomp;
	    if (/^\d+,*\d*$/) # Mass 1 
            {
	    print "Matched: |$`<$&>$'|\n";  # the special match vars
	    } 
            else 
	    {
	    print "No match: |$_|\n";
	    }
	}

