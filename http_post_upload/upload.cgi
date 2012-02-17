#!/usr/bin/perl -T
 
use strict; 
use warnings;

use CGI; 
use CGI::Carp qw ( fatalsToBrowser ); 
use File::Basename; 
$CGI::POST_MAX = 1024 * 5000; 

my $safe_filename_characters = "a-zA-Z0-9_.-"; 
my $upload_dir = "/srv/www/htdocs/upload/"; 
my $query = new CGI; 
my $filename = $query->param("datafile"); 
my $signature = $query->param("signature"); 
my $id = $query->param("id"); 

###############################
# Wurde ein Filename angegeben?
###############################
if ( !$filename ) 
{ 
print $query->header(); 
print "There was a problem uploading your datafile (try a smaller file)."; 
exit; 
}

######################
# Filenamen zerlegen. 
######################
my ( $name, $path, $extension ) = fileparse ( $filename, '\..*' ); 
$filename = $name . $extension; 
$filename =~ tr/ /_/; 
$filename =~ s/[^$safe_filename_characters]//g; 

###########################################
# Enthält der Filename ungültige Zeichen?
###########################################
if ( $filename =~ /^([$safe_filename_characters]+)$/ ) 
{ 
$filename = $1; 
} 
else 
{ 
die "Filename contains invalid characters"; 
} 

##########################
# Der eigentliche Upload.
##########################
my $upload_filehandle = $query->upload("datafile"); 
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!"; 
binmode UPLOADFILE;
 
while ( <$upload_filehandle> ) 
{ 
  print UPLOADFILE; 
} 
close UPLOADFILE; 

################################
# HTML generieren.
################################
if ( $id == "1234567890")
{ 
print $query->header ( ); 
print <<END_HTML; 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"> 

<head> 
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
   <title>Thanks!</title> <style type="text/css"> img {border: none;} </style> 
</head> 

<body> 

    <p>Thanks for uploading your datafile!</p> 

    <p>Your datafile: $filename</p> 
    <p>Your signature: $signature</p> 
    <p>Your ID: $id</p> 
    
    <p><img src="/upload/$filename" alt="Datafile" /></p> 

</body> 

</html> 
END_HTML
}
else
{
print $query->header ( );
print <<END_HTML; 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"> 
 
<head> 
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
    <title>Thanks!</title> <style type="text/css"> img {border: none;} </style> 
</head> 
 
<body> 
 
<p>Sorry, uploading not allowed!</p> 
 
</body> 
 
</html> 
END_HTML
}
