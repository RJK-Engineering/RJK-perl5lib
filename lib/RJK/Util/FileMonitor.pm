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
    my $modified = RJK::Stat->get($self->{file})->modified;

    if ($self->{modified} && $modified != $self->{modified}) {
        $self->notifyObservers({
            type => "FileChanged",
            payload => $self->{file}
        });
    }
    $self->{modified} = $modified;
}

1;
