#!/usr/bin/perl

use Data::Dumper;

# Gundobjekt 1
package Wertigkeit;
 use Moose;

 has 'wert' => ( is => 'rw', required => 1 );


# Grundobjekt 2
package Geldspeicher;
 use Moose;
 use Moose::Util::TypeConstraints;

 has 'Speicher' => ( is => 'rw', isa => 'HashRef[Wertigkeit]' );

sub print {
 my $self = shift;

 foreach my $item ( keys(%{$self->Speicher}) ) {
         my $speicherplatz = $self->{Speicher}{$item};
         print "Anzahl: $item, Object Type: " . $speicherplatz->meta->name
         . "              Wert: " . $speicherplatz->wert . "\n";
 }


}




package main;
 use Moose;

 # Die verschiedenen Münztypen anlegen.
 my $gs1 = Wertigkeit->new( wert => 0.1 );
 my $gs2 = Wertigkeit->new( wert => 0.2 );
 my $gs3 = Wertigkeit->new( wert => 0.5 );
 my $gs4 = Wertigkeit->new( wert => 1 );
 my $gs5 = Wertigkeit->new( wert => 2 );

 # Geld einfüllen
 my %hash1 = ( 3 => $gs1, 4 => $gs2, 10 => $gs3, 6 => $gs4, 3 => $gs5 );

 # Den Automaten aufstellen.
 my $automat = Geldspeicher->new( Speicher => \%hash1 );

 $automat->print();
 #print Dumper $automat;
