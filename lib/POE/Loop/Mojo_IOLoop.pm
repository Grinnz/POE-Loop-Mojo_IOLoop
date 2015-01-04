package POE::Loop::Mojo_IOLoop;

use strict;
use warnings;

our $VERSION = '0.001';

=for poe_tests
sub skip_tests {
	"Mojo::IOLoop tests require the Mojo::IOLoop module" if (
		do { eval "use Mojo::IOLoop"; $@ }
	);
}

package
	POE::Kernel;

=head1 NAME

POE::Loop::Mojo_IOLoop - a bridge that allows POE to be driven by Mojo::IOLoop

=head1 SYNOPSIS

See L<POE::Loop>.

=head1 DESCRIPTION

L<POE::Loop::Mojo_IOLoop> implements the interface documented in L<POE::Loop>.
Therefore it has no documentation of its own. Please see L<POE::Loop> for more
details.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book, C<dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015, Dan Book.

This library is free software; you may redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 SEE ALSO

L<POE>, L<POE::Loop>, L<Mojo::IOLoop>, L<POE::Loop::PerlSignals>

=cut

1;
