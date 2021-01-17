package RJK::Util::ProcessMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

use RJK::Win32::ProcessList;

sub setImageName {
    my $self = shift;
    $self->{imageName} = shift;
}

sub resume {
    my $self = shift;
    $self->{processHash} = $self->getProcessHash();
}

sub doPoll {
    my $self = shift;

    my $previous = $self->{processHash};
    my $processHash = $self->getProcessHash();
    my @spawned;

    foreach my $process (values %$processHash) {
        push @spawned, $process
            if ! $previous->{$process->{PID}};
    }

    $self->notifyObservers({
        type => "ProcessSpawned",
        payload => \@spawned
    }) if @spawned;

    $self->{processHash} = $processHash;
}

sub getProcessHash {
    my $self = shift;
    return RJK::Win32::ProcessList->getProcessHash($self->{imageName});
}

1;
