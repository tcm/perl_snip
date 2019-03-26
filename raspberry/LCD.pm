package LCD;

use strict;
use warnings;

use RPi::Pin;
use RPi::Const qw(:all);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

require  Exporter;

our $VERSION = 0.1;
our @ISA = qw(Exporter);
our @EXPORT = qw(deleteDigit deleteAllDigits switchDigit showDigit showTwoDigits switchSegment);
our @EXPORT_OK = qw(deleteDigit deleteAllDigits switchDigit showDigit showTwoDigits switchSegment);
our %EXPORT_TAGS = ( Functions => [ qw(deleteDigit deleteAllDigits switchDigit showDigit showTwoDigits switchSegment) ] );

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

# Segment an- oder abschalten.
sub switchSegment {
   my $segchar = shift;  # Bezeichnung des Segments
   my $state = shift;	   # Aus oder An (0/1)
   

   my $pin = RPi::Pin->new($segment{$segchar});
   if ($state == 1){
   	$pin->mode(OUTPUT);
   	$pin->write(HIGH);

   } elsif ($state == 0 ) {
   	$pin->mode(OUTPUT);
   	$pin->write(LOW);
   }
}

# Digit 01 oder 10 aktivieren.
sub switchDigit {
   my $state = shift;	   # Digit 01 oder 10 
   
   if ($state eq "01") {
	my $pin = RPi::Pin->new($segment{"01"});
   	$pin->mode(OUTPUT);
   	$pin->write(HIGH);
   	
   	$pin = RPi::Pin->new($segment{"10"});
   	$pin->mode(OUTPUT);
   	$pin->write(LOW);

   } elsif ($state eq "10"  ) {
	my $pin = RPi::Pin->new($segment{"10"});
   	$pin->mode(OUTPUT);
   	$pin->write(HIGH);
   	
   	$pin = RPi::Pin->new($segment{"01"});
   	$pin->mode(OUTPUT);
   	$pin->write(LOW);
   }
}

# Ziffer löschen.
sub deleteDigit{
   
   foreach my $char (split //, $digit{8}) {
	   switchSegment($char,0);
   }
}

# Alle Ziffern löschen.
sub deleteAllDigits{
   
   switchDigit("01");
   deleteDigit;
   switchDigit("10");
   deleteDigit;
}

# Ziffer anzeigen.
sub showDigit{
	my $digitnum = shift; # Eine einstellige Ziffer
   
   foreach my $char (split //, $digit{$digitnum}) {
	   switchSegment($char,1);
   }
}

# 2 Ziffern im Wechsel anzeigen.
sub showTwoDigits{
	my $num = shift; # Eine zweistellige Ziffer
	
	my $digit01 = substr($num,1);
    my $digit10 = substr($num,0,1);

	foreach my $n (1 .. 1000 ) {
	
    switchDigit("10");
    showDigit($digit10);
    deleteDigit;
     
	switchDigit("01");
	showDigit($digit01);
    deleteDigit;
 }
}

1;

