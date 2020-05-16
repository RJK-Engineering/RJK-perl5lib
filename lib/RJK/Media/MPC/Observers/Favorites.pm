package RJK::Media::MPC::Observers::Favorites;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub handleFileChangedEvent {
    my ($self, $ini, $monitor) = @_;
    print "Favorites TODO\n";

    my $favorites = $monitor->getIniSection($ini, "Favorites\\Files");

    use Data::Dump;
    dd $favorites;
}

1;
