package HashClass;
  use Moose;

  has 'mapping' => (
      traits  => ['Hash'],
      is      => 'rw',
      isa     => 'HashRef[Str]',
      default => sub { {} },
      handles => {
          exists_in_mapping => 'exists',
          ids_in_mapping    => 'keys',
          get_mapping       => 'get',
          set_mapping       => 'set',
          set_quantity      => [ set => 'quantity' ],
      },
  );
1;
