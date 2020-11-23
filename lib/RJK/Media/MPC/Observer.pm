package RJK::Media::MPC::Observer;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{name} = shift;
    $self->{controller} = shift;
    $self->{actions} = $self->setupActions($self->{controller});
    return $self;
}

sub setupActions {
}

sub do {
    my ($self, $action) = @_;
    $self->{actions}->$action();
}

sub actions {
    $_[0]{actions}
}

sub utils {
    $_[0]{controller}{utils}
}

1;
