#!/usr/bin/perl

#######################################
# Eine einfache Logfile-Überwachung.
#
# (jb) 29.04.2013
#######################################

use strict;
use warnings;

use v5.10;
use Switch;
# Standard-Module
# use Data::Dumper;
use Net::SMTP;
# CPAN
use Nexmo::SMS;
use IPC::System::Simple qw(system);
use File::Tail;

my $logfile = "/var/log/messages";
my $line;

# Logfile beobachten.
my $file = File::Tail->new($logfile);
while (defined($line=$file->read)) 
{
  print "$line";
  
  # Bei bestimmen Zeileninhalten eine Nachricht versenden.  
  switch ($line)
  {
  case /APC/ { print "Hit APC> ".$line ; &send_sms("0171xxxxxxx", $line); } # Auf Nachrichten der USV lauschen.
  case /UPS/ { print "Hit UPS> ".$line ; &send_sms("0171xxxxxxx", $line); }
  }


}
exit(0);

# SMS über NEXMO oder Failover über SMS-Link versenden.
#
sub send_sms
{
   my ($number,$message) = @_;

   $message = substr($message,0,159);

   say "$number";
   say "$message";

   chomp($message);

   my $nexmo = Nexmo::SMS->new(
   #server   => 'http://rest.nexmo.com/sms/json',
   server   => 'http://rest.nexmo.com/sms/',
   username => '2d4628c0',
   password => 'cba49144',
   );

   my $sms = $nexmo->sms(
   text     => $message,
   from     => 'PASS-Nexmo',
   to       => $number,
   ) or die $nexmo->errstr;

   my $response = $sms->send || warn $sms->errstr;

   if ( $sms->errstr ) 
   {
   say "Try to send SMS via SMS-Link...";
   &send_email("admin\@pass-lokal.com","Warnung: SMS-Versand", "Nexmo-Dienst nicht verfuegbar!"); 
   #system("/usr/local/bin/sendsms -d $number -m 'SMS-Link-Testmessage' localhost");
   system("/usr/local/bin/sendsms -d $number -m '$message' localhost");
   }
   else
   {
   say "SMS was sent via Nexmo!\n" if ( $response->is_success );
   }

}

# Benachrichtigungs-Email generieren.
#
sub send_email
{
    my ($recipient, $subject, $message) = @_;

    my $smtp = Net::SMTP->new('mail.pass-lokal.com');

    $smtp->mail($ENV{USER});
    $smtp->to($recipient);
    $smtp->data();
    $smtp->datasend("To: $recipient\n");
    $smtp->datasend("Subject:".$subject."\n");
    $smtp->datasend("\n");
    $smtp->datasend($message."\n");
    $smtp->dataend();
    $smtp->quit;
}
