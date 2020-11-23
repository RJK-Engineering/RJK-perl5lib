package RJK::Media::MPC::Actions;

sub new {
    my $self = bless {}, shift;
    $self->{controller} = shift;
    return $self;
}

sub console {
    $_[0]{controller}{console};
}

sub opts {
    $_[0]{controller}{opts};
}

sub settings {
    $_[0]{controller}{settings};
}

1;
