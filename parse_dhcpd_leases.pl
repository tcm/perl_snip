#!/usr/bin/perl 

use strict;


# Sehr altes Script, lässt sich eleganter lösen. :-)
# War ein 1-Stunden-Hack.

my $ip;
my $mac;
my $name;
my $dummy;
my $dd;
my @abc;
my %rechner;
my $claenge = 30;
my $flaenge;
my $nspace;
my $space;
my $n;
my $taste;

my $dumn= 0;
my $dumo= 0;

open(dhcp, "/var/lib/dhcp/db/dhcpd.leases") || die "dhcpd.leases ist nicht im gleichen ordner...\n";
while(<dhcp>)
{	chop;
	if(/lease\w*/)
	{	$ip = substr($_, index($_,".")+5, 7);}
	elsif(/hardware\w*/)
	{	$mac = substr($_, rindex($_," "), 18);}
	elsif(/client-hostname\w*/)
	{	$name = substr($_, index($_,"\"")+1, (rindex($_, "\"")-index($_,"\"")-1));
                $name = uc($name);
		$flaenge = length($name);
        }
	elsif($_ eq "}" && $name)
	{	$nspace = $claenge - $flaenge;  
                $space = " " x $nspace;   
                $dummy = "192.168.$ip\t\t$name".$space."$mac";
		$rechner{$ip} = $dummy;
		$ip = "";
		$name = "";
		$mac = "";
		$dummy = "";
	}
}
close(dhcp);
@abc = keys %rechner;
@abc = sort(@abc);
$n = 0;
foreach my $dd (@abc)
{	$dumn = substr($rechner{$dd}, 8, 3);
	if($dumn != $dumo)
	{	print " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n";}
	$dumo = $dumn;
	print "$rechner{$dd}\n";
        $n++;
}
print "\n\n$n Leases vergeben.\n";
my $taste = <STDIN>;

