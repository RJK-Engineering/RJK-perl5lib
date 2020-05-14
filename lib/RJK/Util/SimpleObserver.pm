package RJK::Util::SimpleObserver;
use parent 'RJK::Util::Observer';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{sub} = shift;
    return $self;
}

sub update {
    my ($self, $event) = @_;
    $self->{sub}($event);
}

1;
