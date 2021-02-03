package RJK::Util::FileMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

use RJK::Stat;

sub setFile {
    my $self = shift;
    $self->{file} = shift;
    $self->{modified} = RJK::Stat->get($self->{file})->modified;
}

sub doPoll {
    my $self = shift;
    my $stat = RJK::Stat->get($self->{file});

    if ($self->{modified} && $stat->modified != $self->{modified}) {
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
