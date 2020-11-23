package RJK::Media::MPC::Observers::CopySnapshotToMediaFileDir;
use parent 'RJK::Media::MPC::Observer';

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot, $monitor) = @_;

    $self->utils->getMediaFilePath($snapshot);
    my $dir = $snapshot->{mediaFile}{dir};

    if ($dir) {
        my $file = "$monitor->{snapshotDir}\\$snapshot->{filename}";
        if (File::Copy::copy($file, $dir)) {
            print "Copied $file -> $dir\n";
        } else {
            print "$!: $file -> $dir\n";
        }
    } else {
        print "Media file directory not found.\n";
    }
}

1;
