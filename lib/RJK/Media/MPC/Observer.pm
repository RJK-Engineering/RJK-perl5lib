package RJK::Media::MPC::Observer;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{name} = shift;
    $self->{utils} = shift;
    return $self;
}

sub utils {
    $_[0]{utils}
}

1;
