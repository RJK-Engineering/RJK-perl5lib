package RJK::Media::MPC::Observers::Bookmark;
use parent 'RJK::Media::MPC::SnapshotObserver';

use strict;
use warnings;

use File::Copy ();

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot) = @_;

    $self->retrieveStatus($snapshot);

    if ($snapshot->{mediaFileDir}) {
        my ($self, $snapshot) = @_;
        my $file = "$self->{mpcMon}{opts}{snapshotDir}\\$snapshot->{filename}";
        if (File::Copy::copy($file, $snapshot->{mediaFileDir})) {
            print "Copied $snapshot->{filename}\n";
        } else {
            print "Error moving snapshot to $snapshot->{mediaFileDir}\n";
        }
    } else {
        print "Media file directory not found.\n";
    }
}

1;
