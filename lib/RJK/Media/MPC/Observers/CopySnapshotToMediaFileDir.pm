package RJK::Media::MPC::Observers::CopySnapshotToMediaFileDir;
use parent 'RJK::Media::MPC::Observer';

sub handleSnapshotCreatedEvent {
    my ($self, $snapshot, $monitor) = @_;

    my $mediaFile = $monitor->getMediaFile($snapshot);

    if ($mediaFile->{dir}) {
        my $file = "$monitor->{snapshotDir}\\$snapshot->{filename}";
        if (File::Copy::copy($file, $mediaFile->{dir})) {
            print "Copied $mediaFile->{name}\n";
        } else {
            print "$!: $file -> $mediaFile->{dir}\n";
        }
    } else {
        print "Media file directory not found.\n";
    }
}

1;
