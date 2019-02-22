#!/usr/bin/perl
 
use RPi::Pin;
use RPi::Const qw(:all);

my %segment = ( "d" => 23,
                "c" => 24,
		"e" => 18  ); 

&segment_switch("d",1);
&segment_switch("c",1);
&segment_switch("e",1);


sleep(5);


&segment_switch("d",0);
&segment_switch("c",0);
&segment_switch("e",0);


sub segment_switch {
   my $number = shift;
   my $state = shift;

   my $pin = RPi::Pin->new($segment{$number});
   if ($state == 1){
   	$pin->mode(OUTPUT);
   	$pin->write(HIGH);

   } elsif ($state == 0 ) {
   	$pin->mode(OUTPUT);
   	$pin->write(LOW);
   }
}


exit 0;
