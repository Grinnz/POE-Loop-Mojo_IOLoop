=for poe_tests
BEGIN { $ENV{POE_EVENT_LOOP} = 'POE::Loop::Mojo_IOLoop' }
BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::EV' }
sub skip_tests {
	return "tests for author testing only"
		unless $ENV{AUTHOR_TESTING} or $ENV{AUTOMATED_TESTING};
	return "Mojo::IOLoop tests require the Mojo::IOLoop module" if (
		do { eval "use Mojo::IOLoop"; $@ }
	);
	return "EV module required to test Mojo::Reactor::EV backend" if (
		do { eval "use EV 4.0"; $@ }
	);
	if (shift eq '00_info') {
		my $reactor = Mojo::IOLoop->singleton->reactor;
		diag("Using reactor $reactor");
	}
}
