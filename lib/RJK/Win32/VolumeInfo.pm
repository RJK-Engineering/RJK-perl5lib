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

my $types = {
    DRIVE_UNKNOWN     => DRIVE_UNKNOWN,
    DRIVE_NO_ROOT_DIR => DRIVE_NO_ROOT_DIR,
    DRIVE_REMOVABLE   => DRIVE_REMOVABLE,
    DRIVE_FIXED       => DRIVE_FIXED,
    DRIVE_REMOTE      => DRIVE_REMOTE,
    DRIVE_CDROM       => DRIVE_CDROM,
    DRIVE_RAMDISK     => DRIVE_RAMDISK,
};
sub types { $types }

my %typeFlags = (
    DRIVE_FIXED, '=',
    DRIVE_REMOVABLE, '^',
    DRIVE_REMOTE, '@',
    DRIVE_CDROM, '%',
);
sub typeFlags { \%typeFlags }

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
        my $label = $x[0];

        my $type = GetDriveType($path);

        my $driveLetter = $path;
        $driveLetter =~ s/:\\//;
        $volumes{$driveLetter} = {
            path => $path,
            label => $label,
            driveLetter => $driveLetter,
            type => $type,
            typeFlag => defined $typeFlags{$type} ? $typeFlags{$type} : "?"
        };
    }
    return wantarray ? map { $volumes{$_} } sort keys %volumes : \%volumes;
}

###############################################################################
=begin TML

---++ getDiskFree($volume) -> ($free, $total, $available)

Free/total/available bytes.

=cut
###############################################################################

sub getDiskFree {
    my ($class, $volume) = @_;
    my ($free, $total, $available);
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

    return wantarray ? ($free, $total, $available) : \($free, $total, $available);
}

1;
