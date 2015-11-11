#!/usr/bin/perl

use strict;
use warnings;

use IPC::System::Simple qw(capture);
use Data::Dumper;
use English;

my @switch_names_sw2524 = qw( sw2524-1 sw2524-3 sw2524-4 sw2524-5 sw2524-6 sw2524-7 sw2524-8 sw2524-9 sw2524-10 );
my @switch_names_sw2650 = qw( sw2650-1 );
my @switch_names_sw4208 = qw( sw4208-1 );
my @switch_names_sw5406 = qw( sw5406-1 );

my @ports_sw2524 = (0..24);
my @ports_sw2650 = (0..48);
my @ports_sw4208 = (0, 2, 4..144);
my @ports_sw5406 = (0..72);



my $mac_dec_with_space = qr/\d+\.\d+\.\d+\.\d+\.\d+\.\d+\s/; # Dezimale MAC-Adresse mit Space am Ende
my $digits_at_the_end = qr/\d+$/;                            # Ein oder mehrere Ziffern am Ende

my $snmp_mib = "1.3.6.1.2.1.17.4.3.1.2";
my $count = 0;

#####################
# Hauptprogramm
#
####################

# SW2524
foreach my $switch_name (@switch_names_sw2524)
{
   &query_switch_by_name($switch_name, \@ports_sw2524);
}
# SW2650
foreach my $switch_name (@switch_names_sw2650)
{
   &query_switch_by_name($switch_name, \@ports_sw2650);
}
# SW4208
foreach my $switch_name (@switch_names_sw4208)
{
   &query_switch_by_name($switch_name, \@ports_sw4208);
}
# SW5406
#foreach my $switch_name (@switch_names_sw4208)
#{
#   &query_switch_by_name($switch_name, \@ports_sw4208);
#}

exit 0;

sub query_switch_by_name
{

   my $switch_name = shift;
   my $array_ref = shift; # Ref auf Array mit Portnummern

   my @filtered_port_numbers = ();
   my @command_output = capture("snmpwalk -v 1 -c public $switch_name $snmp_mib");

   # Nur Zeilen mit relevanten Port-Numbers rausfiltern und in Array schreiben.
   # 
   foreach my $port_number ( @$array_ref ){

        foreach my $line (@command_output)
        {
           if ($line =~ /INTEGER: $port_number$/)   # Bei Suchbegriff mit beliebigen Digit am Ende
           {                                        # Zeile in Array übernehmen.
           chomp($line);
           push @filtered_port_numbers, $line;
           }
        }
   }

   # Zeilen auf @filter_port_numbers-Array zerlegen
   # und CSV-Zeile aufbauen
   foreach my $line (@filtered_port_numbers)
   {
        $count++;
        print "$count,$switch_name,";
	if ($line =~ /$mac_dec_with_space/)                                     # MAC-Address
        { 
        my $mac_address_dec = ltrim(${^MATCH});
        print &convert_mac_dec_to_hex($mac_address_dec).","; 
        } 
	if ($line =~ /$digits_at_the_end/) { print "${^MATCH}"."\n"; }          # Port-Number
        
   }

}

sub convert_mac_dec_to_hex
{
   my $address_dec = shift;
   my $address_hex;
   
  my @bytes = split(/\./, $address_dec);

  foreach my $n ( @bytes )
  {
    my $hex = sprintf ("%02x:",$n);
    $address_hex = $address_hex.$hex;
  }
  my $len = length($address_hex);
  return substr($address_hex, 0, $len-1);
}

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };

