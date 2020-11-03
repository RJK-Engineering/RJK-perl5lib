package RJK::Time;

use strict;
use warnings;

sub seconds {
    $_[0]{seconds};
}

sub plus {
    my ($self, $other) = @_;
    bless { seconds => $self->{seconds} + $other->{seconds} }, __PACKAGE__;
}

sub minus {
    my ($self, $other) = @_;
    bless { seconds => $self->{seconds} - $other->{seconds} }, __PACKAGE__;
}

1;
