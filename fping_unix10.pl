#!/usr/bin/perl
require 'open2.pl';

my $MAILTO = "sms\@pass-lokal.com";

my $pid = &open2("OUTPUT","INPUT","/usr/sbin/fping -u");
my $hostnames="unix10";
#my $hostnames="192.168.100.2";
my $int_count;
my $host;

my @check=($hostnames);

open(IN,"</root/hostcount.dat");
while (<IN>) {

	($host,$int_count) = split(",");
}
close(IN);
#print "$host $int_count\n";


foreach(@check) {  print INPUT "$_\n"; }
close(INPUT);
my @output=<OUTPUT>;

if ($#output != -1) {

	chop($date=`date`);
	$int_count++;
chop(@output);

	open(OUT,">/root/hostcount.dat");
	print OUT "@output,$int_count\n";
	close(OUT);

if ($int_count < 3 ) {
    print "$int_count. SMS gesendet.\n";
		
		open(MAIL,"|mail -s '@output --> Since $date : NoPing' $MAILTO");
		print MAIL "blub#01711899991#basicplus\n";
		close MAIL;

		open(MAIL,"|mail -s '@output --> Since $date : NoPing' $MAILTO");
		print MAIL "blub#01774888882#basicplus\n";
		close MAIL;
}

}
