use strict;


my @all_files = <c:\\winnt\\*>;
my $i;
my $dpath = "c:\\ftproot2\\";

$i = 0;

foreach my $file (@all_files) {
	$file =~ s#.*\\##;
	print "$file\n";

	open(OUT, ">$dpath$file");
	close(OUT);
}
