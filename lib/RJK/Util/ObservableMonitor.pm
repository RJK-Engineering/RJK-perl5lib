package RJK::Util::ObservableMonitor;
use parent 'RJK::Util::Monitor';
use parent 'RJK::Util::Observable';

# only polls if observers registered

sub poll { # FINAL
    return if ! @{$_[0]{observers}};
    $_[0]->doPoll();
}

sub doPoll { ... }

sub enable {}

sub disable {}

sub addObserver {
    my $self = shift;
    $self->SUPER::addObserver(@_);
    $self->enable() if @{$self->{observers}} == 1;
}

sub removeObserver {
    my $self = shift;
    $self->SUPER::removeObserver(@_);
    $self->disable() if ! @{$self->{observers}};
}

1;
