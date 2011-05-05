#!/usr/bin/perl

use strict;
use  warnings;

use FindBin '$Bin';
use Template;
use CGI;

$| = 1;
print "Content-type: text/html\n\n";

my $file = 'html.tt';
my $vars = {
    'version'  => 3.14,
    'days'     => [ qw( mon tue wed thu fri sat sun ) ],
    'worklist' => \&get_user_projects,
    'cgi'      => CGI->new(),
    'me'       => {
        'id'     => 'hs',
        'name'   => 'Homer Simpson',
    },
    'email' => 'hs@web.de'
};


sub get_user_projects {
    my $user = shift;
    my @projects = ( 
       { 
	  url       => "http://web.de", 
	  name      => "abc", 
       },
       {
	   url     => "http://yahoo.de",
	   name    => "cde"
       }
    );
    return \@projects;
}

my $template = Template->new({
    INCLUDE_PATH => "$Bin/tt",
    INTERPOLATE  => 1
});

$template->process($file, $vars)
    || die $template->error();

