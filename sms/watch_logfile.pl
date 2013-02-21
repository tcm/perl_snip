#!/usr/bin/perl

use strict;
use warnings;

# Standard-Module
use Data::Dumper;
use IO::Handle;
use File::stat;
# CPAN
use Nexmo::SMS;

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
      	      if (/usv/) # Auf USV-Meldungen lauschen.
      	      {
      	      print $_;
      	      &send_sms("+49171xxxxxxx",$_);
      	      } 
   	   }

           # Warten...., pruefen ob die Datei noch existiert
           # und dann das EOF-Flag loeschen.
           sleep $naptime;
           
           last  if  (stat(*$fh_logfile)->nlink == 0); 
           $fh_logfile->clearerr();
        }
        close($fh_logfile);
        print "Reconnect to file $logfile in $reconnect_time (sec).\n";
        sleep($reconnect_time);        
}

sub send_sms
{
   my ($number,$message) = @_;

   $message = substr($message,0,159);


   print "$number\n";
   print "$message\n";

   my $nexmo = Nexmo::SMS->new(
   server   => 'http://rest.nexmo.com/sms/json',
   #server   => 'http://rest.nexmo.com/sms/',
   username => 'xxxxxxxxx',
   password => 'xxxxxxxxx',
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
   print "SMS was sent via Nexmo!\n" if ( $response->is_success );
   }

}

# Dahin kommen wir nie.... ;-)
exit(0);
