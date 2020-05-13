package RJK::Media::MPC::ProcessMonitor;
use parent 'RJK::Media::MPC::Monitor';

use strict;
use warnings;

use RJK::Win32::ProcessList;

sub init {
    my $self = shift;
    $self->{processHash} = {};
    return $self;
}

sub doPoll {
    my $self = shift;

    my $previous = $self->{processHash};
    my $processHash = getProcessHash();
    my @spawned;

    foreach my $process (values %$processHash) {
        push @spawned, $process
            if ! $previous->{$process->{PID}};
    }
    $self->notifyObservers(\@spawned) if @spawned;
    $self->{processHash} = $processHash;
}

sub getProcessHash {
    return RJK::Win32::ProcessList::GetProcessHash("^mpc-hc");
}

sub getProcessList {
    return RJK::Win32::ProcessList::GetProcessList("^mpc-hc");
}

1;
