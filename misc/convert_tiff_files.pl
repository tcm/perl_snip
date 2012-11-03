#######################################################
# Massen-TIFF Konvertierung zur LZW-Komprimierung.
# Es müssen noch die ImageMagick-Tools installiert sein,
# damit man 'identify' und 'convert' zur Verfügung
# hat.
#
#
# (jb) 2012
#######################################################

#@ARGV = qw(Z:\daten\daten\Bilddateien) unless @ARGV; # Hier steht unser zu durchsuchendes
                                                      # Verzeichnis.
						      #
@ARGV = qw(Z:\Bilddateien) unless @ARGV;              # Hier steht unser zu durchsuchendes
# @ARGV = qw(D:\tiff_test) unless @ARGV;              # Hier steht unser zu durchsuchendes



use File::Find;
# use Digest::SHA1;
# use feature qw/switch/; 

my $ziel_datei = "tiff_sha1.txt";
my $file_name;
my $file;
my $anzahl = 0;
my $without_compression = 0;
my $no_lzw = 0;

sub show_all {

  $file_name = $File::Find::name;
 
  if ($file_name =~ /\.(TIF|tif)/)  # Unser(e) Suchmuster.
  {
  $anzahl++;
  #print "$anzahl.)   $file_name\n";

  
  open my $readme_fh , "-|" ,"identify -verbose \"$file_name\"" || die "Fehler bei fork: $!\n";
  while (<$readme_fh>)
  {
     # Ist das Bild noch nicht komprimiert?
     if ( /Compression: None/ ){  $no_lzw = 1; };
  }
  }

  if ( $no_lzw == 1 ) 
  { 
  print "NO_LZW ==> $file_name\n"; 
  system("convert -compress lzw \"$file_name\" \"$file_name\"");
  $no_lzw = 0;
  }
}


# Main :-)

find (\&show_all, @ARGV);

print "Anzahl: $anzahl\n";
#print "Without Compression: $without_compression\n";

close ($ziel_fh);
