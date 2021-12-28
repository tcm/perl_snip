package Math::Lagfibgen;

use 5.006;
use strict;
use warnings;


use Class::Accessor "antlers";

has j => ( is => "rw", isa => "Num" );
has k => ( is => "rw", isa => "Num" );
has mod => ( is => "rw", isa => "Num" );


#my $obj = Math::Lagfibgen->new({ j => 3, k => 7, mod => 10 });



=head1 NAME

Math::Lagfibgen - The great new Math::Lagfibgen!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Math::Lagfibgen;

    my $foo = Math::Lagfibgen->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
	return "123456";
}

=head2 function2

=cut

sub function2 {
   my $self = shift;
  
   my @seed =  (8, 6, 7, 5, 3, 0, 9);
   my $out;
   my @arr_out = ();

   my $len = scalar @seed;

   for ( my $n = 0; $n < 10; $n++) {
   	for ( my $i = 0; $i < $len; $i++) {

	           #print "$i ";

		   if ( $i == 0 ) {              
		      $out = ($seed[$self->j - 1] + $seed[$self->k - 1]) % $self->mod;  # calculate new element.

                   } elsif ($i > 0 && $i < 6 ) { 
		       $seed[$i] = $seed[$i + 1]; # shift the array to the left.

	           }
	           else {
		      $seed[$i] = $out;         # store the new element in last position of seed array.
		      push @arr_out, $seed[$i]; # store new element in output array.
	           }
         }   
  } 
  return @arr_out;
}

=head1 AUTHOR

Juergen Bachsteffel, C<< <juebac at web.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-math-lagfibgen at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-Lagfibgen>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::Lagfibgen


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-Lagfibgen>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Math-Lagfibgen>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Math-Lagfibgen>

=item * Search CPAN

L<https://metacpan.org/release/Math-Lagfibgen>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2021 Juergen Bachsteffel.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Math::Lagfibgen
