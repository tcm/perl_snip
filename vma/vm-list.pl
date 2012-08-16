#!/usr/bin/perl

use strict;
use warnings;
use VMware::VIFPLib;
use Getopt::Std;

my %opts; 
my $filename;
my $hostname;
getopts('o:h:',\%opts);


# Output-File
if (defined $opts{o})
{
$filename = $opts{o};
}
else
{
print "vm-list.pl -o <Outputfile> -h <Hostname> \n";
print "Example: ./vmlist -o vm_to_backup -h esx1.domain.com\n";
exit 1;
}

# Hostname
if (defined $opts{h})
{
$hostname = $opts{h};
}
else
{
print "vm-list.pl -o <Outputfile> -h <Hostname> \n";
print "Example: ./vmlist -o vm_to_backup -h esx1.domain.com\n";
exit 1;
}



open my $output_fh, '>', $filename || die "Could not open:",$filename;  

my $vima_target = VmaTargetLib::query_target($hostname);
print "Query Host: ".$vima_target->name() . "\n\n";
$vima_target->login();

my $entity_views = Vim::find_entity_views(view_type => "VirtualMachine");

foreach my $entity_view (@$entity_views) 
{
   my $entity_name = $entity_view->name;
   if ( ($entity_view->runtime->powerState->val eq 'poweredOn') )
   {
   print "[$entity_name] is on => Adding to savelist.\n";
   print $output_fh "$entity_name\n";
   } 
   else 
   {
   print "[$entity_name] is off\n";
   }
}
print "\n";

close $output_fh;
