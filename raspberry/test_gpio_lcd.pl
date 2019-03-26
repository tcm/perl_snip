#!/usr/bin/perl
#
use strict;
use warnings;

use RPi::Pin;
use RPi::Const qw(:all);

my %segment = ( "a" => 7,
	        "b" => 8,
	        "d" => 23,
                "c" => 24,
		"e" => 18,
                "f" => 12,
                "g" => 16,
                "dp" => 25,
                "01" => 14,
                "10" => 15 );

my %digit = ( 0 => "abcdef",
              1 => "bc",
              2 => "abged",
              3 => "abgcd",
              4 => "fbgc",
              5 => "afgcd",
              6 => "fedcg",
              7 => "abc",
              8 => "abcdefg",
              9 => "fabgcd",
              dp => "dp");	

#&do_it_all_segments;
&do_it_all_digits;
#&digit_display_two("01",5);


exit 0;

sub do_it_all_digits {
  &segment_switch("01",1,1);
  &segment_switch("10",0,1);
  &test_all_digits;
   
  sleep(3);

  &segment_switch("10",1,1);
  &segment_switch("01",0,1);
  &test_all_digits;
}


sub test_all_digits {

  foreach my $num (0..9) {

      &digit_display($num,1);
   }

}


# Ziffer anzeigen einstellig.
sub digit_display {
   my $num = shift;
   my $delay = shift;

   foreach my $char (split //, $digit{$num}) {
	   &segment_switch($char,1,0);
   }
   sleep($delay);
   foreach my $char (split //, $digit{$num}) {
	   &segment_switch($char,0,0);
   }
}
# Ziffer anzeigen zweistellig.
sub digit_display_two {
   my $num = shift;
   my $delay = shift;
   
   my $digit0 = substr($num,1);
   my $digit1 = substr($num,0,1);

   #print "$digit1, $digit0";
   
   &segment_switch("01",1,1);
   foreach my $char (split //, $digit{$digit0}) {
	   &segment_switch($char,1,0);
   }
   
   &segment_switch("10",1,1);
   foreach my $char (split //, $digit{$digit1}) {
	   &segment_switch($char,1,0);
   }
}

sub do_it_all_segments {
  &segment_switch("01",1,1);
  &segment_switch("10",0,1);
  &test_all_segments;

  &segment_switch("10",1,1);
  &segment_switch("01",0,1);
  &test_all_segments;
}

sub test_all_segments {
   my $teststring="abcdefg";

   foreach my $char (split //, $teststring) {
	   &segment_switch($char,1,1);
   }

   sleep(5);

   foreach my $char (split //, $teststring) {
	   &segment_switch($char,0,1);
   }

}

# Segemnt an- oder abschalten.
sub segment_switch {
   my $number = shift;
   my $state = shift;
   my $delay = shift;

   my $pin = RPi::Pin->new($segment{$number});
   if ($state == 1){
   	$pin->mode(OUTPUT);
   	$pin->write(HIGH);

   } elsif ($state == 0 ) {
   	$pin->mode(OUTPUT);
   	$pin->write(LOW);
   }

   sleep($delay);
}


