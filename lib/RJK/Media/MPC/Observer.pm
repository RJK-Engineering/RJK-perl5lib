package RJK::Media::MPC::Observer;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{mpcMon} = shift;
    return $self;
}

1;