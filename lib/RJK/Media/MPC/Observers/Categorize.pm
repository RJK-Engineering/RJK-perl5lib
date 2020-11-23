package RJK::Media::MPC::Observers::Categorize;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot, $monitor) = @_; # TODO why $monitor param?

    $self->utils->getMediaFilePath($snapshot);
    $self->utils->category->switch($snapshot->{mediaFile});
}

1;
