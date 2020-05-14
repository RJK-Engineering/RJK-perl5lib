package RJK::Util::FileMonitor;
use parent 'RJK::Util::ObservableMonitor';

use strict;
use warnings;

sub setFile {
    my $self = shift;
    $self->{file} = shift;
    $self->{modified} = -M $self->{file};
}

sub doPoll {
    my $self = shift;

    my $modified = -M $self->{file};

    if ($self->{modified} && $modified != $self->{modified}) {
        $self->notifyObservers({
            type => "FileChanged",
            payload => $self->{file}
        });
    }
    $self->{modified} = $modified;
}

1;
