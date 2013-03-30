#!/usr/bin/perl

use strict;
use warnings;

use v5.10;
use Switch;
# Standard-Module
# use Data::Dumper;
use IO::Handle;
use File::stat;
use Net::SMTP;
# CPAN
use Nexmo::SMS;
use IPC::System::Simple qw(system);

my $naptime = 1;
my $reconnect_time = 120;
my $logfile = "/var/log/messages";
# my $logfile = "./messages";

while(1)
{
        
        print "Connect to file $logfile.\n";
	open my $fh_logfile, "<" , $logfile or die "Kann die Datei '$logfile' nicht oeffnen: $!";
           

	# I. Einmal bis zum Ende der Datei springen.
	while (<$fh_logfile>){ }
	$fh_logfile->clearerr();

	# II. Ab jetzt das Ende der Datei beobachten. 
	while(1)
	{
   
   	   while (<$fh_logfile>)
   	   {
              print $_;
              switch ($_)
              {
              case /APC/ { print "Hit APC> ".$_ ; &send_sms("0171xxxxxxxx", $_); } # Auf Nachrichten der USV lauschen.
              case /UPS/ { print "Hit UPS> ".$_ ; &send_sms("0171xxxxxxxx", $_); }
              }
   	   }

           # Warten...., pruefen ob die Datei noch existiert
           # und dann das EOF-Flag loeschen.
           sleep $naptime;
           
           last  if  (stat(*$fh_logfile)->nlink == 0); 
           $fh_logfile->clearerr();
        }
        close($fh_logfile);
        say "Reconnect to file $logfile in $reconnect_time (sec).";
        sleep($reconnect_time);        
}

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
   username => 'xxxxxxxxxx',
   password => 'xxxxxxxxxx',
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
   system("/usr/local/bin/sendsms -d $number -m '$message' localhost");
   }
   else
   {
   say "SMS was sent via Nexmo!\n" if ( $response->is_success );
   }

}

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

# Dahin kommen wir nie.... ;-)
exit(0);
