use strict;
use warnings;

use Test::More tests => 2;
use_ok('POE', 'Loop::Mojo_IOLoop');
is(POE::Kernel->poe_kernel_loop(), 'POE::Loop::Mojo_IOLoop',
	'Using Mojo::IOLoop event loop for POE');

# idea from Test::Harness, thanks!
diag("Testing POE $POE::VERSION, Perl $], $^X on $^O");
