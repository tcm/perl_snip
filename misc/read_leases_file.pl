#!/usr/bin/perl

use Text::DHCPparse;
use English;

my $filter10 = qr/192\.168\.10\./;
my $filter100 = qr/192\.168\.100\./;
my $filter111 = qr/192\.168\.111\./;
my $filter200 = qr/192\.168\.200\./;
 
$return = leaseparse('./dhcpd.leases');

print "\n\n";
&show_range($filter10);
&show_range($filter100);
&show_range($filter111);
&show_range($filter200);

sub show_range {

	my $filter = shift;
        my $count = 0;

        $count = 0;
	foreach (sort keys %$return) {

	   ($ip, $time, $mac, $name) = unpack("A17 A21 A19 A30", $return->{$ARG});
	   if ( $ip =~ /$filter/ ) { 
               printf ("%15s  %15s  %15s %20s\n", $ip, $mac, $name, $time); 
               $count++;
	   }
	}
	print "---------------------------------------------------------------------------\n";
        print "$count Host(s)\n\n";
}
