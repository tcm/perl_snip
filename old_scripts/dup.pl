#!/usr/bin/perl
use strict;


my @all_files = glob 'c:\\winnt\\*';
my $i;
my $dpath = "c:\\ftproot2\\";

$i = 0;

foreach my $file (@all_files) {
	$file =~ s#.*\\##;
	print "$file\n";

	open my $fh_out, '>', $dpath.$file;
	close($fh_out);
}
