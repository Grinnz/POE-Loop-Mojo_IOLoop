use strict;

package POE::Loop::Mojo_IOLoop;

use POE::Loop::PerlSignals;

our $VERSION = '0.001';

=for poe_tests
BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }
use POE 'Loop::Mojo_IOLoop';
sub skip_tests {
	"Mojo::IOLoop tests require the Mojo::IOLoop module" if (
		do { eval "use Mojo::IOLoop"; $@ }
	);
}

=cut

package
	POE::Kernel;

use Mojo::IOLoop;
use Time::HiRes;

my $_timer_id;
my @fileno_watcher;

# Loop construction and destruction.

sub loop_initialize {
	my $self = shift;
	
	$_timer_id = Mojo::IOLoop->timer(0 => \&_loop_event_callback);
}

sub loop_finalize {
	my $self = shift;
	
	foreach my $fd (0..$#fileno_watcher) {
		POE::Kernel::_warn(
			"Filehandle watcher for fileno $fd is defined during loop finalize"
		) if defined $fileno_watcher[$fd];
	}
	
	$self->loop_ignore_all_signals();
}

# Signal handler maintenance functions.

sub loop_attach_uidestroy {
	# does nothing
}

# Maintain time watchers.

sub loop_resume_time_watcher {
	my ($self, $next_time) = @_;
	$next_time -= Time::HiRes::time;
	Mojo::IOLoop->remove($_timer_id) if defined $_timer_id;
	$_timer_id = Mojo::IOLoop->timer($next_time => \&_loop_event_callback);
}

sub loop_reset_time_watcher {
	my ($self, $next_time) = @_;
	$self->loop_pause_time_watcher();
	$self->loop_resume_time_watcher($next_time);
}

sub loop_pause_time_watcher {
	return unless defined $_timer_id;
	Mojo::IOLoop->remove($_timer_id);
	undef $_timer_id;
}

# Maintain filehandle watchers.

sub loop_watch_filehandle {
	my ($self, $handle, $mode) = @_;
	my $fileno = fileno $handle;
	
	# Set up callback if needed
	unless (defined $fileno_watcher[$fileno]) {
		Mojo::IOLoop->singleton->reactor->io($handle => sub {
			my ($reactor, $writable) = @_;
			_loop_select_callback($fileno, $writable);
		});
	}
	
	my $read = $fileno_watcher[$fileno][MODE_RD()] ||= ($mode == MODE_RD);
	my $write = $fileno_watcher[$fileno][MODE_WR()] ||= ($mode == MODE_WR);
	
	Mojo::IOLoop->singleton->reactor->watch($handle, $read, $write);
}

sub loop_ignore_filehandle {
	my ($self, $handle, $mode) = @_;
	my $fileno = fileno $handle;
	
	# Don't bother changing mode unless it was registered
	if ($fileno_watcher[$fileno][$mode]) {
		my $read = $fileno_watcher[$fileno][MODE_RD()] &&= !($mode == MODE_RD);
		my $write = $fileno_watcher[$fileno][MODE_WR()] &&= !($mode == MODE_WR);
		
		if ($read or $write) {
			Mojo::IOLoop->singleton->reactor->watch($handle, $read, $write);
		} else {
			Mojo::IOLoop->singleton->reactor->remove($handle);
			undef $fileno_watcher[$fileno];
		}
	}
}

sub loop_pause_filehandle {
	my ($self, $handle, $mode) = @_;
	my $fileno = fileno $handle;
	
	my $read = $fileno_watcher[$fileno][MODE_RD()] && !($mode == MODE_RD);
	my $write = $fileno_watcher[$fileno][MODE_WR()] && !($mode == MODE_WR);
	
	Mojo::IOLoop->singleton->reactor->watch($handle, $read, $write);
}

sub loop_resume_filehandle {
	my ($self, $handle, $mode) = @_;
	my $fileno = fileno $handle;
	
	my $read = $fileno_watcher[$fileno][MODE_RD()] || ($mode == MODE_RD);
	my $write = $fileno_watcher[$fileno][MODE_WR()] || ($mode == MODE_WR);
	
	Mojo::IOLoop->singleton->reactor->watch($handle, $read, $write);
}

# Timer callback to dispatch events.

sub _loop_event_callback {
	my $self = $poe_kernel;
	
	$self->_data_ev_dispatch_due();
	$self->_test_if_kernel_is_idle();
	
	# Transferring control back to Mojo::IOLoop; this is idle time.
}

# Mojo::IOLoop filehandle callback to dispatch selects.

sub _loop_select_callback {
	my $self = $poe_kernel;
	my ($fileno, $writable) = @_;
	
	my $mode = $writable ? MODE_WR : MODE_RD;
	
	$self->_data_handle_enqueue_ready($mode, $fileno);
	$self->_test_if_kernel_is_idle();
}

# The event loop itself.

sub loop_do_timeslice {
	Mojo::IOLoop->one_tick;
}

sub loop_run {
	Mojo::IOLoop->start;
}

sub loop_halt {
	Mojo::IOLoop->stop;
}

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
