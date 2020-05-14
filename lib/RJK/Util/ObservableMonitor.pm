package RJK::Util::ObservableMonitor;
use parent 'RJK::Util::Monitor';
use parent 'RJK::Util::Observable';

sub poll {
    my $self = shift;
    return if ! @{$self->{observers}};
    $self->doPoll();
}

sub doPoll { ... }

1;
