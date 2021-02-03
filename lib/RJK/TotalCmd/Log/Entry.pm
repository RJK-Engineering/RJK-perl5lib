package RJK::TotalCmd::Log::Entry;

use strict;
use warnings;

use Class::AccessorMaker {
    date => undef, time => undef,
    sourcedir => undef, sourcefile => undef, source => undef,
    destdir => undef, destfile => undef, destination => undef,
    operation => undef, isFsPluginOp => undef,
    success => undef, error => undef, skipped => undef,
    user => undef, encoding => undef
};

sub getOpMsg {
    my $self = shift;
    return $self->{error}
        || $self->{skipped} && "Skipped"
        || $self->{success} && "Success"
        || $self->{user} && ($self->{encoding} ? "$self->{user}, $self->{encoding}" : $self->{user})
        || "No message";
}

1;
