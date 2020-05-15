package RJK::Media::MPC::Observer;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{mpcMon} = shift;
    return $self;
}

sub utils {
    $_[0]{mpcMon}{utils}
}

1;
