package RJK::Path;

use strict;
use warnings;
no warnings 'redefine';

use RJK::Paths;

our $separator;

sub names {
    my @names = split /\Q$separator\E/, $_[0]{path};
    shift @names if $_[0]{volume};
    return wantarray ? @names : \@names;
}

sub subpath {
    my ($self, $begin, $end) = @_;
    my @path = splice @{$self->names}, $begin, $end;
    RJK::Paths->get($self->driveletter, @path);
}

sub parent {
    return '' if $_[0]{name} eq '';
    RJK::Paths->get($_[0]->driveletter, $_[0]{directories});
}

sub root {
    $_[0]{volume} || return;
    RJK::Paths->get($_[0]{volume} . ':' . $separator);
}

sub driveletter {
    $_[0]{volume} || return;
    $_[0]{volume} . ':';
}

1;
