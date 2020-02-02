package RJK::TotalCmd::Log::Entry;

use strict;
use warnings;

use Class::AccessorMaker {
    date => undef,
    time => undef,
    operation => undef,
    fsPluginOp => undef,
    ok => undef,
    error => undef,
    skipped => undef,
    user => undef,
    encoding => undef,
    source => undef,
    destination => undef,
};

sub operationOk {
    my $self = shift;
    return ! $self->{error}
        && ! $self->{skipped};
}

sub getOpMsg {
    my $self = shift;
    return $self->{error}
        || $self->{skipped} && "Skipped";
}

1;
