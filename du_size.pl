#!/usr/bin/perl
  
############################################################
# Das Script zerpflueckt die Ausgabe von 'du -akx'
# und sucht nach den größten Files.
# (jb) 2011
############################################################

use strict;
use warnings;

use Data::Dumper;
use Getopt::Std;

my %opts;
my $quell_file;

getopts('i:', \%opts);


if (defined $opts{i}) 
{
$quell_file = $opts{i};
}
else
{
print "du_size.pl -i <Eingabefile>\n";
exit 1;
}

# Max-Size in (MB)
my $big_size = 200;

open my $readme_fh , "zcat  $quell_file|" || die "Fehler bei fork: $!\n";

while (<$readme_fh>)
{
   chomp;
   my ($size, $path) = split(/\t/);
   $size = $size / 1000;
    
   if ($path =~ m/((\.tar)?\.[a-zA-Z0-9_-]+)$/ )
   # Alternativ-Regex.
   # if ($path =~ /\.([^\.]+)$/ )
   {
   if ( $size >= $big_size)
   {
   printf ("%f MB -> $path\n", $size);
   }
   }
} 
exit 0; 
