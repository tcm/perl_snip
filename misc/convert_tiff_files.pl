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
@ARGV = qw(c:\pictures\temp) unless @ARGV;            
use File::Find;
use Digest::SHA1;

my $ziel_datei = "tiff_sha1.txt";
my $file_name;
my $file;
my $anzahl;
my $without_compression;

sub show_all {

 $file_name = $File::Find::name;
 
 if ($file_name =~ /\.(TIF|tif)/) {                    # Unser(e) Suchmuster.
	
   open my $readme_fh , "-|" ,"identify -verbose $file_name" || die "Fehler bei fork: $!\n";
   while (<$readme_fh>)
   {
      
      # Ist das Bild noch nicht komprimiert?	  
      if ( /Compression: None/ )
      {
      open(FILE, $file_name) or die "Can't open '$file_name': $!";
      binmode(FILE);

      # Ein paar Infos in einer Textdatei ablegen,
      # damit man weiß wo man war, falls das Script
      # abbricht.
      print $ziel_fh Digest::SHA1->new->addfile(*FILE)->hexdigest.", ";
      print $ziel_fh $file_name.", ".$_; 

      $without_compression++;

      system("convert -compress lzw $file_name $file_name");

      };

   }
   close($readme_fh);
   $anzahl++;
 }
}


# Main :-)
open $ziel_fh, '>', $ziel_datei || die "$ziel_datei konnte nicht geoeffnet werden.\n";

find (\&show_all, @ARGV);

print "Anzahl: $anzahl\n";
print "Without Compression: $without_compression\n";

close $ziel_fh;
