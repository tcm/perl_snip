#!/usr/bin/perl

package Row;

    use Moose;
    use Data::Dumper;

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


# Versuch einen Recordset mit Moose
# zubilden. Will noch nicht gelingen.
# Vielleicht so nicht sinnvoll?
my $recordset_ref= [];

my $r_obj = Row->new;

$r_obj->options(["count" => 1, "name" => "foo"]);
push(@{ $recordset_ref },  $r_obj );

$r_obj->options(["count" => 2, "name" => "bar"]);
push(@{ $recordset_ref },  $r_obj );

print Dumper $recordset_ref;
#my $count = $r_obj->count_options;
#print "$count\n"; # prints 4

#my @options = $r_obj->all_options;
#print "@options\n"; # prints "foo bar baz boo"
