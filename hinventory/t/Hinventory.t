#!/usr/bin/perl

###############################################################
# Modul-Tests
# (jb) 2011
###############################################################

use strict;
use warnings;


use Test::More tests => 3;

use Path::Class;
use FindBin '$Bin';
use Hinventory;

use Data::Dumper;

######################################
# I. hinventory_gen_recordset testen.
######################################
my $str_path = file($Bin,"xml_test", "*.xml");

#############
# 1. Firefox
############
my $recordset_ref = [];                   # Anonymes Array für die Datensaetze
my $suchbegriff_name = "Firefox";
my $rs_count_soll = 3;
my $rs_count_ist = 0;

hinventory_gen_recordset($recordset_ref, "Application", $suchbegriff_name,  $str_path);
#print Dumper $recordset_ref;
$rs_count_ist = @{ $recordset_ref };
ok($rs_count_soll == $rs_count_ist, "hiventory_gen_recordset: Korrekte Datensatzanzahl $rs_count_ist\/$rs_count_soll.");


##############
# 2. IGateway
##############
$recordset_ref = [];                   # Anonymes Array für die Datensaetze
$suchbegriff_name = "iGateway";
$rs_count_soll = 2;
$rs_count_ist = 0;

hinventory_gen_recordset($recordset_ref, "Application", $suchbegriff_name,  $str_path);
#print Dumper $recordset_ref;
$rs_count_ist = @{ $recordset_ref };
ok($rs_count_soll == $rs_count_ist, "hiventory_gen_recordset: Korrekte Datensatzanzahl $rs_count_ist\/$rs_count_soll.");


##############
# 3. All Apps
##############
$recordset_ref = [];                   # Anonymes Array für die Datensaetze
$suchbegriff_name = "";
$rs_count_soll = 123;
$rs_count_ist = 0;
$str_path = file($Bin,"xml_test", "pc1.xml");

hinventory_gen_recordset($recordset_ref, "Application", $suchbegriff_name,  $str_path);
#print Dumper $recordset_ref;
$rs_count_ist = @{ $recordset_ref };
ok($rs_count_soll == $rs_count_ist, "hiventory_gen_recordset: Korrekte Datensatzanzahl $rs_count_ist\/$rs_count_soll.");



#test_recordset($recordset_ref);


# ok( 1 + 1 == 2, "One and one is two!" );
# ok( "Steve" =~ /steve/i, "Steve matches steve" );
# ok( defined( `hostname` ), "Hostname produced .. something" );


sub test_recordset 
{
   my $rs_ref = shift;
   my $n = 0;
	
   foreach my $rec ( @{ $rs_ref }  ) 
   { 
      ok($rec->{'count'} =~ /^\d+$/, "Zeile $n Feld <count> enthaelt eine Ziffer.");
      ok($rec->{'filename'} =~ /\b([A-Za-z0-9-_]+)\b\.xml/, "Zeile $n Feld <filename> hat das richtige Format (Endung .xml).");
      ok($rec->{'name'} =~ /$suchbegriff_name/, "Zeile $n Feld <name> enthaelt Suchbegriff: $suchbegriff_name.");
      ok($rec->{'createtime'} =~ /\d\d-\d\d-\d\d\d\d \d\d:\d\d/,  "Zeile $n Feld <createtime> hat das richtige Datums-Format.");
      

      print "\n";
      $n++;
   }
 }

 
