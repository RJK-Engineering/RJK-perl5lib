package RJK::Media::MPC::SnapshotMonitor;
use parent 'RJK::Media::MPC::Monitor';

use strict;
use warnings;

use Win32;

use RJK::Media::MPC::Snapshot;

use Class::AccessorMaker {
    snapshotDir => undef,
    unlinkSnapshots => 0
};

sub init {
    my $self = shift;
    $self->reset;
    return $self;
}

sub resume {
    my $self = shift;
    $self->reset();
}

sub doPoll {
    my $self = shift;

    my $snapshots = $self->getSnapshots();
    my @snapshotsCreated;

    while (my ($file, $snapshot) = each %$snapshots) {
        next if $self->{prevSnapshots}{$file};
        push @snapshotsCreated, $snapshot;
    }

    $self->{prevSnapshots} = $snapshots;

    foreach (@snapshotsCreated) {
        $self->notifyObservers({
            type => "SnapshotCreated",
            payload => $_
        });
        $self->cleanupSnapshot($_->{filename});
    }
}

sub reset {
    my $self = shift;
    $self->{prevSnapshots} = $self->getSnapshots();
}

###############################################################################
=pod

---+++ getSnapshots() -> \%snapshots
   * =%snapshots= - =RJK::Media::MPC::Snapshot= objects hashed by filename

Create =RJK::Media::MPC::Snapshot= objects for all snapshot files stored
in =snapshotDir=.

=cut
###############################################################################

sub getSnapshots {
    my $self = shift;
    my %snapshots;

    opendir my $dh, $self->{snapshotDir} or die "$!";

    foreach (readdir $dh) {
        next if ! /\.(jpg|png)$/i;
        my $snapshot = $self->newSnapshot($_);
        $snapshots{$_} = $snapshot;
    }
    closedir $dh;

    return \%snapshots;
}

sub newSnapshot {
    my ($self, $filename) = @_;

    my $file = "$self->{snapshotDir}\\$filename";
    if (! -f $file) {
        warn "Not a file: $file";
        return;
    }

    my $snapshot = new RJK::Media::MPC::Snapshot($filename);
    if ($snapshot) {
        # get unicode version of the path name
        if (my $longpath = Win32::GetLongPathName($file)) {
            $snapshot->{longpath} = $longpath;
            $snapshot->{longname} = $longpath =~ s/(.*)\\//r;
            $snapshot->{longdir} = $1;
        }
        return $snapshot;
    } else {
        print "WARN Invalid filename: $filename";
    }
}

sub cleanupSnapshot {
    my ($self, $filename) = @_;
    return if ! $self->{unlinkSnapshots};
    unlink "$self->{snapshotDir}/$filename";
}

1;
