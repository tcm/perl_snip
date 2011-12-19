#!/usr/bin/perl
use strict;
use warnings;

use threads;
use threads::shared;
use DBI;
use POSIX qw(strftime);
   
print "Starting main program...\n\n";

my $C_MAX = 20;

my @arr1 = 
( 
"EXEC proc1",

"EXEC proc2",

"select * from T1"
);

####################
# Threads erzeugen.
####################
my @threads;
my $anz_arr1;

$anz_arr1 = @arr1;

for ( my $count = 1; $count <= $C_MAX; $count++)
{
  my $int_rand_sql=int(rand($anz_arr1));
  my $t = threads->new(\&launch_sql_queries, $count, $arr1[$int_rand_sql]);
  push(@threads,$t);
}

##########################
# Threads-Status abfragen.
###########################
foreach (@threads)
{
   my $num = $_->join;
   print strftime('[%H:%M:%S] ', localtime);
   print "done thread $num\n";
}
print "\nEnd of main program...\n";
exit 0;


###################
# Thread-Routinen.
##################
sub launch_sql_queries
{
    my ($num, $statement) = @_;

    my $sec = int(rand(10))+1;
    sleep($sec); 
    print strftime('[%H:%M:%S] ', localtime);
    print "thread $num delay($sec)\n";

    ###########################
    # Connection Parameter
    ###########################
    my $dsn = "CON1";
    my $usr = "user1";
    my $pwd = "xxxxxxxx";
    my $dbh = DBI->connect("dbi:ADO:$dsn", $usr, $pwd ) or die $DBI::errstr;

    ############################
    # SELECT 1: prepare
    ############################
    print strftime('[%H:%M:%S] ', localtime);
    print "thread $num delay($sec)";
    print substr($statement,0 , 25)."\n";

    my $sth = $dbh->prepare( $statement ) or die $dbh->errstr;
    $sth->execute();

    ############################
    # INSERT 2: 
    ############################
    
    ############################
    # UPDATE 3: 
    ############################   
    

    # Close DB
    if ($dbh->err()) { die "$DBI::errstr\n"; }
    $dbh->disconnect();
   
    return $num;
}
