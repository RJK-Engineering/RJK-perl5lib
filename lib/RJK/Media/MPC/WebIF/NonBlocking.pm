=begin TML

---+ package RJK::Media::MPC::WebIF::NonBlocking

=cut

package RJK::Media::MPC::WebIF::NonBlocking;
use parent RJK::Media::MPC::WebIF;

use strict;
use warnings;
use threads;

use Thread::Queue;

sub new {
    my $self = shift->SUPER::new(@_);
    my %opts = @_;

    $self->{callback} = $opts{callback};
    $self->{errorCallback} = $opts{errorCallback};

    return $self;
}

sub init {
    my $self = shift->SUPER::init();

    # Use queue to avoid waiting for a response (fire-and-forget)
    $self->{commandQueue} = Thread::Queue->new();
    $self->{requestThread} = threads->create(
        sub {
            while (defined(my $command = $self->{commandQueue}->dequeue)) {
                my $response = $self->sendCommand($command);
                if ($response->is_success) {
                    $self->{callback}($response) if $self->{callback};
                } else {
                    $self->{errorCallback}($response) if $self->{errorCallback};
                }
            }
        }
    );

    return $self;
}

###############################################################################
=pod

---++ sendCommandNonBlocking($commandId)
   * =$commandId= - Command ID.

Send command in separate thread. Enqueues command which is dequeued by the
request thread.

---++ exit()
Accept no more requests and wait for queued requests to finish. Ends the
command queue and waits for the request thread to complete.

=cut
###############################################################################

sub sendCommandNonBlocking {
    my ($self, $command) = @_;
    $self->{commandQueue}->enqueue($command);
}

sub exit {
    my $self = shift;
    $self->{commandQueue}->end();
    $self->{requestThread}->join();
}

1;
