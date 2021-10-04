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

    if ($stat->modified != $self->{stat}->modified || $stat->size != $self->{stat}->size) {
        $self->notifyObservers({
            type => "FileChangeEvent",
            payload => {
                file => $self->{file},
                stat => $stat
            }
        });
    }
    $self->{stat} = $stat;
}

1;
