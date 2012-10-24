use strict;

        while (<>) 
        {                   # take one input line at a time
	    chomp;
	    if (/\.prt\.\d+$/) 
            {
	    print "Matched: |$`<$&>$'|\n";  # the special match vars
	    } 
            else 
	    {
	    print "No match: |$_|\n";
	    }
	}

