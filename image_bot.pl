#!/usr/bin/perl

#  Imagebot um den Umgang mit Images zu erleichtern.
#
# (jb) 2007


use strict;

use File::stat;
use File::Find;
use Data::Dumper;

my @all_files;
my $i;
my $path = "/images/clients";
my $clientname;
my $clientname_orig;
my $pos_point;
my $d_path;
my $taste;
my $sb;
my $timestamp;

#######################################################
# Schleife fuer Hauptverzeichnis
#######################################################

while(1) {

	while (1) {
		# Filter in einem Array zusammenfassen.
		# 
		my @files1 = </images/*.pqi>;
		my @files2 = </images/*.tib>;
		my @files3 = </images/*.TIB>;
		my @files4 = </images/*.PQI>;

		# Filter addieren
		#
		my @all_files;
		@all_files = (@files1, @files2, @files3, @files4);

		open(OUT1, ">>timestamp.dat") || die "Die Datei timestamp.dat konnte nicht geoeffnet werden.\n";

		print "-------------------------\n";
		print "Ansicht: Hauptverzeichnis\n";
		print "Wechseln mit: 99\n";
		print "-------------------------\n";
	

		# Ausgabe formatieren
		$i = 0;
		foreach my $file (@all_files) {
    	$sb = stat($file);                    # Fileliste anzeigen, mit Groesse und Create-Time.
	    printf "$i) %.15s,            %8.0fMB,               %.25s\n", $file, 
		($sb->size/(1024*1024)), scalar localtime $sb->atime;
    	$i++;
	    }

		# Eingabeaufforderung ausgeben.
		#
		print ">";
		$taste = <STDIN>;
		chop($taste);

		if ($taste eq "99" ){
	 		last; # verlassen der while-Schleife
		} elsif ($taste eq "") {
		    last;
		}
		

		# Clientnamen extrahieren.
		# clienname enthaelt den Namen in Kleinbuchstaben
		# und clientname_orig in Orginalschreibweise.
	
		$clientname = $all_files[$taste]; 
		$clientname =~ s#.*/##;  			                         # Pfad abschneiden.
		$pos_point = index($clientname, ".");		                 # Position des Punktes bestimmen.
		$clientname = substr($clientname, 0, $pos_point);            # Name ohne Punkt liefern.
	
		$clientname_orig = $clientname;								 # Clientnamen in Orginalschreibweise merken. 
		$clientname = lc($clientname);                               # In Kleinschreibung umwandeln.
    	print "\n";

		$d_path = $path."/".$clientname;							 # Pfad fuer das Clientverzeichnis
	
		if (-e $d_path) {
		print "Verzeichnis  $d_path existiert bereits.\n";           # I. Wenn der Pfad existiert, dann
		$timestamp = scalar localtime $sb->atime;                    # Datum in einer Datei  
		print OUT1 "$clientname | $timestamp\n";                     # im Arbeitsverzeichnis sichern

		print "rm $d_path/*\n";							             # Inhalt loeschen
		system ("rm $d_path/*");
	
		print "mv $clientname_orig.* $d_path\n";                     # und Image verschieben.
		system ("mv $clientname_orig.* $d_path");
		
		close (OUT1);
	

		} else {
			print "Verzeichnis $d_path existiert nicht.\n";          # II. Wenn der Pfad nicht existiert, dann
            $timestamp = scalar localtime $sb->atime;                    # Datum in einer Datei 
            print OUT1 "$clientname | $timestamp\n";                     # im Arbeitsverzeichnis sichern
			                                                             # und zusaetzlich im client-Verzeichnis.

	        print "mkdir  $d_path\n";                                    # Verzeichnis anlegen
			system ("mkdir  $d_path");
		
			print "mv $clientname_orig.* $d_path\n";                 # und Image verschieben.
			system("mv $clientname_orig.* $d_path");
			
			close(OUT1);
		}

		print "\n<Taste druecken>";                                  
		$taste = <STDIN>;

	}

#######################################################
# Schleife fuer Image-Verzeichnisse
#######################################################
		   
	while (1) {
		print "----------------------------\n";
		print "Ansicht: Image-Verzeichnisse\n";
		print "Wechseln mit: 99\n";
		print "----------------------------\n";
				   

     	@ARGV = qw(/images/clients) unless @ARGV; # Hier steht unser zu durchsuchendes
	    	                                       # Verzeichnis.

	 	@all_files = ();     											   
     	find (\&show_all, @ARGV);
	 
     	# Ausgabe formatieren
     	$i = 0;
	 	foreach my $file (@all_files) {
		 	$sb = stat($file);                    # Fileliste anzeigen, mit Groesse und Create-Time.
		 	printf "$i) %.25s,            %8.0fMB,               %.25s\n", $file,
		 	($sb->size/(1024*1024)), scalar localtime $sb->atime;
		  $i++;
	 	}
									
	 	# print Dumper @all_files; 
		
	 	# Eingabeaufforderung ausgeben.
	 	#
	 	print ">";
	 	$taste = <STDIN>;
	 	chop($taste);

	  	if ($taste eq "99" ){
	    	  last; # verlassen der while-Schleife
	   	} elsif ($taste eq "") {
		   last;
		}
		
					   


	
		$clientname = $all_files[$taste];

		print "mv $clientname .\n";                 # Image verschieben.
		system("mv $clientname .");
			
	
	    print "\n<Taste druecken>";
		$taste = <STDIN>;
	}
}

# Unterprogramm das alle Kandidaten im Unterverzeichnis sucht und die Namen in ein Array
# schiebt.
sub show_all {
	    my $file_name = $File::Find::name;

	    if ($file_name =~ /\.tib/ or $file_name =~ /\.PQI/ ) { # Unser(e) Suchmuster.
			push(@all_files, $file_name);
		}
}
										 
