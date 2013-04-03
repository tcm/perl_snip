#!/usr/bin/perl

use strict;
use warnings;

use v5.10;
use Net::Ping::External qw(ping);
use Net::SMTP;
use POSIX qw(strftime); 

my @check_switch = qw(swxxxxx-1  swxxxx-3 );

my @check_host = qw(vm-server-1 vm-server-2);

my @check_ap = qw(ap-1 ap-2);

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
