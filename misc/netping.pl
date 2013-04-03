#!/usr/bin/perl

use strict;
use warnings;

use v5.10;
use Net::Ping::External qw(ping);
use Net::SMTP;
use POSIX qw(strftime); 

my @check_switch = qw(sw4208-1 sw2524-1 sw2524-3 sw2524-4 sw2524-5 sw2524-6 sw2524-7 sw2524-8 sw2524-9);

my @check_host = qw(vm-w2003-1 vm-w2003-2 vm-w2003-3 vm-xp-1 vm-sles10-1 nt1 vm-w2000srv-1 nt4 nt6 unix4
                  vm-sles11-1 unix10 firewall ntws1 bildmaster1 bildmaster2 faxserver mail vm-w2003-4 
                  vm-w2008-1 vm-w2008-2 vm-w2008-3 nt2 vm-debian3-0-1 vm-suse10-3-3 nas-2 nas-5);

my @check_ap = qw(ap4000m-1 ap4000m-2);

my @hosts = (@check_switch , @check_host , @check_ap );


  #my $num_not_alive = 0;
  foreach (@hosts) 
  {

   # Using all the fancy options:
   #ping(hostname => "127.0.0.1", count => 5, size => 1024, timeout => 3);
   my $alive = ping(hostname => $_, timeout => 5);

   unless ( $alive )
   {
   #$num_not_alive++;
   my $time = strftime('%d-%m-%Y %H:%M', localtime);
   say "$_ is not alive!";
   &send_email("pingadmin\@pass-lokal.com", "Host [$_] is unreachable since $time");
   }


  }

sub send_email
{
    my ($recipient, $message) = @_;

    my $smtp = Net::SMTP->new('mail.pass-lokal.com');

    $smtp->mail($ENV{USER});
    $smtp->to($recipient);
    $smtp->data();
    $smtp->datasend("To: $recipient\n");
    $smtp->datasend("Subject: Unreachable Host\n");
    $smtp->datasend("\n");
    $smtp->datasend($message."\n");
    $smtp->dataend();
    $smtp->quit;
}

exit 0;
