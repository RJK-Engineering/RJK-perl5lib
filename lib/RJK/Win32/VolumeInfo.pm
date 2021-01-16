=begin TML

---+ package RJK::Win32::VolumeInfo

* drive not mapped/mounted
? DRIVE_UNKNOWN     None of the following.
? DRIVE_NO_ROOT_DIR A "drive" that does not have a file system. This can be a drive letter that hasn't been defined or a drive letter assigned to a partition that hasn't been formatted yet.
^ DRIVE_REMOVABLE   A floppy diskette drive or other removable media drive, but not a CD-ROM drive.
= DRIVE_FIXED       An ordinary hard disk partition.
@ DRIVE_REMOTE      A network share.
% DRIVE_CDROM       A CD-ROM drive.
? DRIVE_RAMDISK     A "ram disk" or memory-resident virtual file system used for high-speed access to small amounts of temporary file space.

=cut

package RJK::Win32::VolumeInfo;

use strict;
use warnings;

$^O =~ /mswin/i or die "Wrong OS";

use Win32API::File qw(
    getLogicalDrives GetVolumeInformation GetDriveType
    :DRIVE_);

###############################################################################
=begin TML

---++ getVolumes() -> \%volumes or @volumes

=cut
###############################################################################

sub getVolumes {
    my %volumes;
    my @drives = getLogicalDrives();
    foreach my $path (@drives) {
        my @x = (undef)x7;
        GetVolumeInformation($path, @x);
        my $type = GetDriveType($path);

        my $driveLetter = $path;
        $driveLetter =~ s/:\\//;
        $volumes{$driveLetter} = {
            path => $path,
            label => $x[0],
            serial => $x[2],
            fs => $x[5],
            letter => $driveLetter,
            type => $type
        };
    }
    return wantarray ? map { $volumes{$_} } sort keys %volumes : \%volumes;
}

###############################################################################
=begin TML

---++ getUsage($volume) -> ($free, $total, $available) or { free => $free, total => $total, available => $available }

Free/total/available bytes.

=cut
###############################################################################

sub getUsage {
    my ($class, $volume) = @_;
    my ($free, $total, $available);
    $volume =~ s/:?$/:/;
    my @lines = `fsutil volume diskfree $volume`;

    foreach (@lines) {
        if (/Total # of free bytes\s*:\s*(\d+)/) {
            $free = $1;
        } elsif (/Total # of bytes\s*:\s*(\d+)/) {
            $total = $1;
        } elsif (/Total # of avail free bytes\s*:\s*(\d+)/) {
            $available = $1;
        }
    }

    die $lines[0] if ! $free;

    return wantarray ? ($free, $total, $available) : {
        free => $free,
        total => $total,
        available => $available
    }
}

1;
