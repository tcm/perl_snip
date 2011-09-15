#!/usr/bin/perl


use Data::Dumper;

package  Stuff;

    use Moose;

    has 'options' => (
       traits     => ['Array'],
       is         => 'rw',
       isa        => 'ArrayRef[Str]',
       default    => sub { [] },
       handles    => {
           all_options    => 'elements',
           add_option     => 'push',
           map_options    => 'map',
           filter_options => 'grep',
           find_option    => 'first',
           get_option     => 'get',
           join_options   => 'join',
           count_options  => 'count',
           has_options    => 'count',
           has_no_options => 'is_empty',
           sorted_options => 'sort',
       },
    );

my $stuff = Stuff->new;
$stuff->options(["foo", "bar", "baz", "boo"]);

my $count = $stuff->count_options;
print "$count\n"; # prints 4

my @options = $stuff->all_options;
print "@options\n"; # prints "foo bar baz boo"




