#!/usr/bin/perl

# Creates shell-commands for a ESX-Server vm-backup.
# The last snapshot will be saved or if no snapshot exists the base-machine.
# 


# Juergen Bachsteffel / 2007

use strict;
use File::Basename;
use File::Path;
use Data::Dumper;
use Getopt::Std;


my %opts;
my $host_dir;
getopts('i:', \%opts);  

if (defined $opts{i}) {
	$host_dir = $opts{i};
} else {
	print "Fehler: Option -i <hostdir> muss angegeben werden.\n";
        exit 1;	
}

my $path1 = "/vmfs/volumes/storage1";
my $path2 = "/backup/vmware";

my @arr1 = glob '$path1/$host_dir/*.vmdk';
my @arr2;
my @arr3;

my $file;
my $source_dir;
my $dest_dir = $path2."/".$host_dir;
my $n;

#
# if arr1 has no entries, then quit.
if (@arr1) {
	$source_dir = dirname(@arr1[0]);
} else {
   
	print "Fehler: Keine vmdk-Files gefunden.\n";
	exit 1;
}
# print Dumper @arr1;

#
# Open output-file
#
my $outfile = $host_dir.".sh";
open my $fh_shellfile, '>', $outfile or
	die "$outfile konnte nicht angelegt werden.\n";

#
#  copy all relevant
#  vmdk-files to
#  arr2.
foreach my $file (@arr1) {
	$file = basename($file);
	
	if ($file =~ /-flat/) {
		# do nothing
	} elsif ($file =~ /-delta/) {
		# do nothing
	} else {
		push (@arr2, $file);					
	}
}
print "\n";
# print Dumper @arr2;

#
# copy only vmdk-Files with 6 digits
# before a point in arr3. 
foreach my $file (@arr2) {
	if ($file =~ /\d{6}\./) {
                push (@arr3, $file);	
	}
}	
print "\n";
# print Dumper @arr3;

#
# create shell-commands.
print "\n";
print "#!/bin/bash\n";
print $fh_shellfile "#!/bin/bash\n";
print "IN=$source_dir\n";
print $fh_shellfile "IN=$source_dir\n";
print "OUT=$dest_dir\n\n";
print $fh_shellfile "OUT=$dest_dir\n\n";

print "vmware-cmd  \$IN/$host_dir.vmx stop\n"; 
print $fh_shellfile "vmware-cmd  \$IN/$host_dir.vmx stop\n"; 
print "sleep 30\n\n"; 
print $fh_shellfile "sleep 30\n\n"; 

print "rm -v \$OUT/*\n";
print $fh_shellfile "rm -v \$OUT/*\n";

print "cp -v \$IN/$host_dir.vmx \$OUT\n";
print $fh_shellfile "cp -v \$IN/$host_dir.vmx \$OUT\n";

# create dest-dir if it does not exist.
if ( !(-e $dest_dir)) {
	mkpath($dest_dir);
}
#
# CASE1: no snapshots exists.
# arr3 has no entries.
# relevant entries are only in arr2.

$n = @arr3;
if ($n == 0) {

	
	# create commands.
	foreach my $file (@arr2) {
		
		print "vmkfstools -i \$IN/$file -d 2gbsparse \$OUT/$file\n";
		print $fh_shellfile "vmkfstools -i \$IN/$file -d 2gbsparse \$OUT/$file\n";
	}	
} else {
 #
 # CASE2: snapshots exists.
 # There are entries in arr3.
 # Only this entries are relevant.
 	
	my %hash1;
 	
	foreach my $file ( sort @arr3) {
		
	        #
		# last point, last minus
		# get length.	
		my $pos_pnt = rindex($file,".");
		my $pos_bs = rindex($file, "-");
		my $laenge = length($file);

		#
		# part1: to minus
		# part2: 6 digits
		# part3: end with point
		my $part1 = substr($file, 0, $pos_bs);
		my $part2 = substr($file, $pos_bs+1, $pos_pnt-$pos_bs-1);
		my $part3 = substr($file, $pos_pnt, $laenge-$pos_pnt);

		# print $part1."   ".$part2."    ".$part3."\n";
		$hash1{$part1} = $part2;

	}	 
	#
	# part1: is key
	# part2: is 6-digit-value
	# print hash
	foreach my $key (keys %hash1) {
		# print "$key -> $hash1{$key}\n";
		print "vmkfstools -i \$IN/$key-$hash1{$key}.vmdk -d 2gbsparse \$OUT/$key.vmdk\n";
		print $fh_shellfile "vmkfstools -i \$IN/$key-$hash1{$key}.vmdk -d 2gbsparse \$OUT/$key.vmdk\n";
	}

}


print "\nvmware-cmd  \$IN/$host_dir.vmx start\n\n"; 
print $fh_shellfile "\nvmware-cmd  \$IN/$host_dir.vmx start\n\n"; 


close($fh_shellfile);
chmod(0755,$outfile);



