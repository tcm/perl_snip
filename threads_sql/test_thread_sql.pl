#!/usr/bin/perl
# This is compiled with threading support
#  
use strict;
use warnings;

use threads;
use threads::shared;
use DBI;
   
print "Starting main program\n";


# Threads erzeugen.    
my @threads;

for ( my $count = 1; $count <= 10; $count++) 
{
  my $t = threads->new(\&sub1, $count);
  push(@threads,$t);
}

# Threads abarbeiten.
foreach (@threads) 
{
   my $num = $_->join;
   print "done with $num\n";
}
print "End of main program\n";
exit 0;


# Thread-Routine.                                    
sub sub1 
{
    my $num = shift;
    print "started thread $num\n";
    sleep $num;

    my $dbargs = {AutoCommit => 0, PrintError => 1};
    my $dbh = DBI->connect("dbi:SQLite:dbname=testdata.db", "", "", $dbargs);


    my $f2 = int(rand(26)+65);
    my $f1 = chr($f2) x 5;

    # INSERT
    # my $sql = "INSERT INTO t1 (f1,f2) VALUES ('$f1', $f2)";
    # print "$sql\n";
    # my $sth = $dbh->do( $sql );
    # $dbh->commit; 


    # SELECT
    my ($field1, $field2) = "";
    my $sql = "SELECT f1,f2 FROM t1 where f2 = $f2";
    my $res = $dbh->selectall_arrayref( $sql );
    foreach my $row (@$res) 
    {
      ($field1, $field2) = @$row;
      print("Row: $field1, $field2\n");
    }



    # Close DB
    if ($dbh->err()) { die "$DBI::errstr\n"; }
    $dbh->disconnect();
    

    print "done with thread $num\n";
    return $num;
}
