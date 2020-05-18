package RJK::Media::MPC::Util;

sub new {
    my $self = bless {}, shift;
    $self->{controller} = shift;
    return $self;
}

sub opts {
    $_[0]{controller}{opts};
}

sub settings {
    $_[0]{controller}{settings};
}

1;
