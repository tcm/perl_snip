#!/usr/bin/perl
 {
 package MyWebServer;
 
 use HTTP::Server::Simple::CGI;
 use base qw(HTTP::Server::Simple::CGI);
 
 my %dispatch = (
     '/hello' => \&resp_hello,
     '/dienst' => \&resp_dienst
      # ...
 );
 
 sub handle_request {
     my $self = shift;
     my $cgi  = shift;
   
     my $path = $cgi->path_info();
     my $handler = $dispatch{$path};
 
     if (ref($handler) eq "CODE") {
         print "HTTP/1.0 200 OK\r\n";
         $handler->($cgi);
         
     } else {
         print "HTTP/1.0 404 Not found\r\n";
         print $cgi->header,
               $cgi->start_html('Not found'),
               $cgi->h1('Not found'),
               $cgi->end_html;
     }
 }
 
 sub resp_hello {
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;
     
     my $who = $cgi->param('name');
     
     print $cgi->header,
           $cgi->start_html("Hello"),
	   $cgi->h1("Dienstmanager"), 
	   ("Button drücken um den Dienst neu zu starten."),

	  
	   ("<form action=\"http://vm-xp-test.domain-lokal.com:8080/dienst\">"),
	   ("<input type=\"submit\" value=\" Absenden\">"),
	   ("<input type=\"reset\" value=\" Abbrechen\">"),
	   ("</form>"),
	   
           $cgi->end_html;
 }
 


 sub resp_dienst {
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;
     
     my $who = $cgi->param('name');
     
     print $cgi->header,
           $cgi->start_html("Dienst-Neustart"),
	   $cgi->h1("Dienst neu starten."), 
           $cgi->end_html;
           
	   system("serviceshutdown");
	   sleep(6);
	   system("servicestartserver");
 }





 } 
 
 # start the server on port 8080
 my $pid = MyWebServer->new(8080)->background();
 print "Use 'kill $pid' to stop server.\n";

