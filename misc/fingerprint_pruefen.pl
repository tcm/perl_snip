#!/usr/bin/perl
use English;

my $i = 0;
my $command = "/usr/bin/fetchmail -V -f /root/.fetchmailrc 2>&1";
my $myfile = "/root/.fetchmailrc";
#my $myfile = "./.fetchmailrc_test";
my $myregex_fingerprint = qr/[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+:[0-9A-Z]+/;
my $fingerprint_mailserver = "1----";
my $fingerprint_fetchmailrc = "2----";
my @lines;

###################################################
# Die Datei .fetchmailrc auslesen.
###################################################
open my $configfile_fh, "<", $myfile or die "Can't open $myfile: $!";
while (<$configfile_fh>)
{
  push (@lines,$ARG);
}
foreach my $line (@lines)
{      
	#print $i.". ".$line;
        $i++;
  if ($line =~ /$myregex_fingerprint/)
  {
        #print $i.". <$MATCH>\n";
        $fingerprint_fetchmailrc = $MATCH;
  }

}
close($configfile_fh);

###################################################
# Die Ausgabe für das Kommando 'fetchmail' auslesen.
####################################################
$i=0;
open my $command_fh , "-|" , $command || die "Fehler bei fork: $!\n";
while (<$command_fh>)
{ 
  #print $i.". ". $_;
  $i++;
  if (/$myregex_fingerprint/)
  {
  	#print $i.". <$MATCH>\n";
        $fingerprint_mailserver = $MATCH;        
  }

}
close($command_fh);

##################################################
# ...und vergleichen :-)
##################################################
if ($fingerprint_mailserver ne $fingerprint_fetchmailrc)
{
	print "Achtung, der Fingerprint ist unterschiedlich!\n\n";
        print "Mail-Server: $fingerprint_mailserver\n";
        print "/root/.fetchmailrc: $fingerprint_fetchmailrc\n\n";
}

exit 0;
