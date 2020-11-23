package RJK::Media::MPC::Observers::Category;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

use RJK::Media::MPC::Actions::Category;

sub setupActions {
    my ($self, $controller) = @_;
    return new RJK::Media::MPC::Actions::Category($controller);
}

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot, $monitor) = @_;

    $self->utils->getMediaFilePath($snapshot);
    $self->actions->switch($snapshot->{mediaFile});
}

1;
