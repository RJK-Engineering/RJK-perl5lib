package RJK::FileSystem;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    return $self;
}

sub separator {
    return "\\";
}

1;
