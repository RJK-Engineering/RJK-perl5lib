###############################################################################
=begin TML

---+ package RJK::Win32::VolumeInfo

=cut
###############################################################################

package RJK::Win32::VolumeInfo;

use strict;
use warnings;

$^O =~ /mswin/i or die "Wrong OS";

use Win32API::File qw(
    getLogicalDrives GetVolumeInformation GetDriveType
    :DRIVE_);

###############################################################################
=pod

---++ Class methods

---+++ getVolumes() -> \%volumes or @volumes

Volume type value reference: https://metacpan.org/pod/Win32API::File#GetDriveType

=cut
###############################################################################

sub getVolumes {
    my %volumes;
    my @drives = getLogicalDrives();
    foreach my $path (@drives) {
        my @x = (undef)x7;
        GetVolumeInformation($path, @x);
        my $type = GetDriveType($path);

        my $letter = $path =~ s/\\//r;
        $volumes{$letter} = {
            path => $path,
            label => $x[0],
            serial => $x[2],
            fs => $x[5],
            letter => $letter,
            name => $letter =~ s/://r,
            type => $type
        };
    }
    return wantarray ? map { $volumes{$_} } sort keys %volumes : \%volumes;
}

###############################################################################
=pod

---+++ getUsage($volume) -> ($free, $total, $available) or { free => $free, total => $total, available => $available }

Free/total/available bytes.

=cut
###############################################################################

sub getUsage {
    my ($self, $volume) = @_;
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
