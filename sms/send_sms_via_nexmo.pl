#!/usr/bin/perl

use strict;
use warnings;

 use Nexmo::SMS;

    my $nexmo = Nexmo::SMS->new(
        server   => 'http://rest.nexmo.com/sms/json',
        username => 'xxxxxxxx',
        password => 'xxxxxxxx',
    );
    
    my $sms = $nexmo->sms(
        text     => 'This is a test',
        from     => 'Test123',
        to       => '+491711234567',
    ) or die $nexmo->errstr;
    
    my $response = $sms->send || die $sms->errstr;
    
    if ( $response->is_success ) {
        print "SMS was sent...\n";
    }
