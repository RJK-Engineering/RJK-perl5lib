package RJK::Drives;

use strict;
use warnings;

use RJK::Win32::VolumeInfo;

my $volumes;

sub getDriveLetter {
    my ($self, $label) = @_;
    my @drives;
    foreach (values %{getVolumeInfo()}) {
        next if $_->{label} !~ /^\Q$label\E$/i;
        push @drives, $_->{drive};
    }
    die "Duplicate volume labels \"$label\" found in drives: @drives" if @drives > 1;
    return $drives[0];
}

sub getLabel {
    my ($self, $diskPath) = @_;
    my $mountPoint = $self->getMountPoint($diskPath);
    return getVolumeInfo()->{$mountPoint}{label};
}

# returns mount point (drive letter on MSWin32)
sub getMountPoint {
    my ($self, $diskPath) = @_;
    ($diskPath =~ /^(\w:)/)[0] // die "Invalid path: $diskPath";
}

# returns path without mount point
sub getPathOnVolume {
    my ($self, $diskPath) = @_;
    $diskPath =~ s/^\w://r // die "Invalid path: $diskPath";
}

sub getVolumeInfo {
    $volumes //= RJK::Win32::VolumeInfo->getVolumes();
}

1;
