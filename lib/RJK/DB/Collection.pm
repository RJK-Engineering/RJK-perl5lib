package RJK::DB::Collection;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    #~ $self->{name} = shift;
    return $self;
}

1;
