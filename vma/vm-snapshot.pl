#!/usr/bin/perl

###############################################
# Snapshots mit bestimmten Alter suchen.
#
# (jb) Mai 2013
###############################################
use strict;
use warnings;
use VMware::VIFPLib;
use Getopt::Std;
use Date::Parse;
use POSIX qw/ceil/;
#use Data::Dumper;

my %opts; 
my $hostname;
my @old_snapshots;
getopts('h:',\%opts);



# Hostname
if ( defined $opts{h} )
{
$hostname = $opts{h};
}
else
{
print "vm-snapshot.pl -h <Hostname> \n";
print "Example: ./vm-snapshot -h esx1.domain.com\n";
exit 1;
}

my $vima_target = VmaTargetLib::query_target($hostname);
print "Query Host: [--- ".$vima_target->name() . " ---]\n\n";

$vima_target->login();

# Alle virtuellen Maschinen im Inventory.
my $entity_views = Vim::find_entity_views(view_type => "VirtualMachine");

# Hostname und Snapshotname auflisten.
foreach my $entity_view ( @$entity_views ) 
{
   my $entity_name = $entity_view->name;
   my $entity_snapshot = $entity_view->snapshot;

   # Nur angeschaltete Maschinen betrachten.
   if ( ($entity_view->runtime->powerState->val eq 'poweredOn') )
   {
   #print "[$entity_name] is on.\n";

   # Existiert überhaupt ein Snapshot?
   if ( defined ($entity_snapshot) ) 
   { 
   #print "<$entity_snapshot>\n"; 
   #print "<$entity_snapshot->{rootSnapshotList}>\n";

   # Snapshots durchlaufen und auf ihr Alter prüfen. 
   &check_snaplist($entity_name, $entity_snapshot->{rootSnapshotList} );

   #print Dumper $entity_snapshot;
   }
   } 
   else 
   {
   #print "[$entity_name] is off.\n";
   }
}
print "\n";

if ( scalar(@old_snapshots) > 0 )
{
print "Old Snapshots found.\n";

map 
{
   printf "%s (%s Days) \n",
   $_->{'vm'}, $_->{'age'}

} @old_snapshots;

}

print "\n";
exit 0;

###############################################
# Snapshot-Alter prüfen.
# 1 Day = 86400s
# 3 Days = 259200s
# 1 Week = 604800s
################################################
sub check_age 
{
   my $date_created = shift;

   return(1) if( (time() - $date_created) > 86400);
   return(0);
}

#################################################
# Über die Snapshots iterieren. 
#################################################
sub check_snaplist 
{
   my $vm_name = shift;
   my $vm_snaptree = shift;

   foreach my $vm_snapshot ( @{$vm_snaptree} ) 
   {
      my $date_snapshot = str2time($vm_snapshot->{createTime});
      next unless ( check_age($date_snapshot) );

      $old_snapshots[scalar(@old_snapshots)] = 
      {
         'vm' => $vm_name,
         'age' => ceil(( (time() - $date_snapshot) / 86400)),
      };

   }
}
