package RJK::Util::FileMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

use RJK::Stat;

sub setFile {
    my $self = shift;
    $self->{file} = shift;
    $self->{stat} = RJK::Stat->get($self->{file});
}

sub doPoll {
    my $self = shift;
    my $stat = RJK::Stat->get($self->{file});

    if (not $self->fileExists) {
        $self->notifyObservers("FileCreateEvent", $self->getPayload($stat)) if $stat->exists;
    }
    elsif (not $stat->exists) {
        $self->notifyObservers("FileDeleteEvent", $self->getPayload($stat));
    }
    elsif ($stat->modified != $self->{stat}->modified
    or $stat->size != $self->{stat}->size) {
        $self->notifyObservers("FileChangeEvent", $self->getPayload($stat));
    }
    $self->{stat} = $stat;
}

sub fileExists {
    $_[0]{stat}->exists;
}

sub getPayload {
    my ($self, $stat) = @_;
    payload => {
        file => $self->{file},
        stat => $stat
    };
}

1;
