package ArrayClass;

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
1;
