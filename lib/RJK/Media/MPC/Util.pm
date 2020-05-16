package RJK::Media::MPC::Util;

sub new {
    my $self = bless {}, shift;
    $self->{mpcMon} = shift;
    return $self;
}

sub opts {
    $_[0]{mpcMon}{opts};
}

sub settings {
    $_[0]{mpcMon}{settings};
}

1;
