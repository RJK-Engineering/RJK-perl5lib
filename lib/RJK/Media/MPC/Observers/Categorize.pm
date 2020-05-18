package RJK::Media::MPC::Observers::Categorize;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot, $monitor) = @_;

    $monitor->utils->getMediaFilePath($snapshot);
    $monitor->utils->category->switch($snapshot->{mediaFile});
}

1;
