#!/usr/bin/perl

use strict;
use warnings;
use Net::POP3;
use Nexmo::SMS;


my $hostname = "mail.domain.com";
my $username = "user1";
my $password = "xxxxxxx";

my $pop = Net::POP3->new($hostname, Timeout => 60);

if ($pop->login($username, $password) > 0) 
{
my $msgnums = $pop->list; # hashref of msgnum => size

foreach my $msgnum (keys % {$msgnums} ) 
{
   my $msg = $pop->get($msgnum);
   foreach my $line ( @{ $msg } ) 
   {
      if ($line =~ /^Subject: UPS/) 
      {
      print $line;
	
      my $nexmo = Nexmo::SMS->new(
      server   => 'http://rest.nexmo.com/sms/json',
      username => 'xxxxxxxxx',
      password => 'xxxxxxxxx',
      );
      
      my $sms = $nexmo->sms(
      text     => 'UPS Switched to battery backup power.',
      from     => 'IT-Admin',
      to       => '+491711234567',
      ) or die $nexmo->errstr;

      my $response = $sms->send || die $sms->errstr;

      if ( $response->is_success ) 
      {
      print "SMS was sent...\n";
      }
      }

    }
    #print @{ $msg };
    }
}

$pop->quit;
