package RJK::Media::MPC::Observers::Bookmark;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot, $monitor) = @_;

    $monitor->utils->getMediaFilePath($snapshot);
}

sub handleFileChangedEvent {
    my ($self, $ini, $monitor) = @_;

    my $favorites = $monitor->getIniSection($ini, "Favorites\\Files");

    use Data::Dump;
    dd $favorites;
}

1;
