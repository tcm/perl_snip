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
      	      &send_sms($_);
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
   my $message = shift;

   my $nexmo = Nexmo::SMS->new(
   server   => 'http://rest.nexmo.com/sms/json',
   username => 'xxxxxxx',
   password => 'xxxxxxx',
   );

   my $sms = $nexmo->sms(
   text     => $message,
   from     => 'PASS-Admin',
   to       => '+49171xxxxxxxx',
   ) or die $nexmo->errstr;

   my $response = $sms->send || die $sms->errstr;

   if ( $response->is_success )
   {
   print "SMS was sent...\n";
   }
}




# Dahin kommen wir nie.... ;-)
exit(0);
