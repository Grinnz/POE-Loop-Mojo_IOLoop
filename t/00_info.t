use strict;
use warnings;

use Test::More tests => 3;
use_ok('Mojo::IOLoop');
use_ok('POE');
is(POE::Kernel::poe_kernel_loop(), 'POE::Loop::Mojo_IOLoop',
	'Using Mojo::IOLoop event loop for POE');

# idea from Test::Harness, thanks!
diag("Testing POE $POE::VERSION, Perl $], $^X on $^O");
