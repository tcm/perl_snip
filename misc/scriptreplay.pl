#!/usr/bin/perl -w
use strict;

# Record:
# script -t 2> s1.timing -a s1.session
#
# Replay (bash):
# scriptreplay s1.timing s1.session 1
#
# Replay (perl):
# scriptreplay.pl s1.timing s1.session 1

$|=1;
open (TIMING, shift)
        or die "cannot read timing info: $!";
open (TYPESCRIPT, shift || 'typescript')
        or die "cannot read typescript: $!";

my $divisor=shift || 1;
my $start_sec=shift || 0;
my $end_sec=shift;

# Read starting timestamp line and ignore.
<TYPESCRIPT>;
my $printing = ($start_sec > 0 ? 0 : 1);
my $elapsed = 0;
my $block;
my $oldblock='';

while (<TIMING>) {
        my ($delay, $blocksize)=split ' ', $_, 2;
        if ($printing && ($delay / $divisor > 0.0001)) {
                select(undef, undef, undef, $delay / $divisor - 0.0001);
        }
        read(TYPESCRIPT, $block, $blocksize) or die "read failure: $!";
        print $oldblock if ($printing);

        $elapsed += $delay;
        exit if ((defined $end_sec) && ($elapsed > $end_sec));
        $printing = ($elapsed > $start_sec);

        $oldblock=$block;
}
print $oldblock;
