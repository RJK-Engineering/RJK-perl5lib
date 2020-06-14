package RJK::Filecheck::Site;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my $attr = shift || {};
    $self->{$_} = $attr->{$_} for keys %$attr;
    return $self;
}

sub downloadUrl {
    my ($self, $id) = @_;
    my $url = sprintf "$self->{protocol}://$self->{host}/$self->{downloadPath}", $id;
    return $url;
}

sub searchUrl {
    my ($self, $query) = @_;
    my $url = sprintf "$self->{protocol}://$self->{host}/$self->{searchPath}", $query;
    return $url;
}

1;
