#!/usr/bin/perl
require 'open2.pl';

$MAILTO = "sms\@domain-lokal.com";

$pid = &open2("OUTPUT","INPUT","/usr/sbin/fping -u");

@check=("unix10");
#@check=("192.168.100.2");

foreach(@check) {  print INPUT "$_\n"; }
close(INPUT);
@output=<OUTPUT>;

if ($#output != -1) {
chop($date=`date`);
open(MAIL,"|mail -s '@output --> Since $date : NoPing' $MAILTO");
print MAIL "blub#01711859899#basicplus\n";
close MAIL;

open(MAIL,"|mail -s '@output --> Since $date : NoPing' $MAILTO");
print MAIL "blub#01714545899#basicplus\n";
close MAIL;


}
