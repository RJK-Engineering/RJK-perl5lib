package RJK::Util::FileMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

use RJK::Stat;

sub setFile {
    my $self = shift;
    $self->{file} = shift;
    my $stat = RJK::Stat->get($self->{file});
    $self->{modified} = $stat->modified;
    $self->{size} = $stat->size;
}

sub doPoll {
    my $self = shift;
    my $stat = RJK::Stat->get($self->{file});

    if ($stat->modified != $self->{modified} || $stat->size != $self->{size}) {
        $self->notifyObservers({
            type => "FileChanged",
            payload => {
                file => $self->{file},
                stat => $stat
            }
        });
    }
    $self->{modified} = $stat->modified;
}

1;
