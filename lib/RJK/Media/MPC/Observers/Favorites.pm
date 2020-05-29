package RJK::Media::MPC::Observers::Favorites;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub handleFileChangedEvent {
    my ($self, $ini, $monitor) = @_;

    my $favorites = $self->{favorites};
    $self->getFavorites($ini, $monitor);
    return if ! $favorites;
    return if $favorites eq $self->{favorites};

    # compare $favorites $self->{favorites}

    use Data::Dump;
    dd $favorites;
}

sub getFavorites {
    my ($self, $ini, $monitor) = @_;
    $self->{favorites} = $monitor->getIniSection($ini, "Favorites\\Files");
}

1;
