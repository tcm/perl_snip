#!/usr/bin/perl
 
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

my %digit = ( 0 => "abcdef" );	

#&do_it_all;
&digit_switch(0,1);

sub digit_switch {
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


sub do_it_all {
  &segment_switch("01",1,1);
  &segment_switch("10",0,1);
  &test_all_segments;

  &segment_switch("10",1,1);
  &segment_switch("01",0,1);
  &test_all_segments;
}

sub test_all_segments {
   &segment_switch("a",1,1);
   &segment_switch("b",1,1);
   &segment_switch("c",1,1);
   &segment_switch("d",1,1);
   &segment_switch("e",1,1);
   &segment_switch("f",1,1);
   &segment_switch("g",1,1);
   &segment_switch("dp",1,1);
   sleep(5);
   &segment_switch("a",0,1);
   &segment_switch("b",0,1);
   &segment_switch("c",0,1);
   &segment_switch("d",0,1);
   &segment_switch("e",0,1);
   &segment_switch("f",0,1);
   &segment_switch("g",0,1);
   &segment_switch("dp",0,1);
}


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


exit 0;
