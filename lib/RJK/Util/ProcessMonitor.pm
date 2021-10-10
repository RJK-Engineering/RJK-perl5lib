package RJK::Util::ProcessMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

use RJK::Win32::ProcessList;

sub setImageName {
    my $self = shift;
    $self->{imageName} = shift;
}

sub init {
    my $self = shift;
    $self->{processHash} = $self->getProcessHash();
}

sub doPoll {
    my $self = shift;

    my $previous = $self->{processHash};
    my $processHash = $self->getProcessHash();
    my @spawned;

    foreach my $process (values %$processHash) {
        next if not $self->{imageName}
            and RJK::Win32::ProcessList->ignore($process);
        $self->notifyObservers("ProcessSpawnEvent", payload => $process)
            if not $previous->{$process->{PID}};
    }
    foreach my $process (values %$previous) {
        next if not $self->{imageName}
            and RJK::Win32::ProcessList->ignore($process);
        $self->notifyObservers("ProcessGoneEvent", payload => $process)
            if not $processHash->{$process->{PID}};
    }
    $self->{processHash} = $processHash;
}

sub getProcessHash {
    my $self = shift;
    return RJK::Win32::ProcessList->getProcessHash();
}

1;
