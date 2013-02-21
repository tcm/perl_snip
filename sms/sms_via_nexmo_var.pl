#!/usr/bin/perl

use strict;
use warnings;

# Standard-Module
use Data::Dumper;
# CPAN
use Nexmo::SMS;

send_sms("+49171xxxxxxxxx","Hallo!");



sub send_sms
{
   my ($number,$message) = @_;

   $message = substr($message,0,159);


   print "$number\n";
   print "$message\n";

   my $nexmo = Nexmo::SMS->new(
   #server   => 'http://rest.nexmo.com/sms/json',
   server   => 'http://rest.nexmo.com/sms/',
   username => 'xxxxxxxx',
   password => 'xxxxxxxx',
   );


   my $sms = $nexmo->sms(
   text     => $message,
   from     => 'User1',
   to       => $number,
   ) or die $nexmo->errstr;

   my $response = $sms->send || warn $sms->errstr;

   if ( $sms->errstr ) 
   {
   print "SMS was not sent...\n";
   system("echo 'Nexmo-Dienst nicht verfuegbar!' | mail -s 'Warnung: SMS-Versand' admin\@pass-lokal.com");
   }
   else
   {
   print "SMS was sent!\n" if ( $response->is_success );
   }

}

exit(0);
