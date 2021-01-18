###############################################################################
=begin TML

---+ package RJK::Win32::DriveUtils

=cut
###############################################################################

package RJK::Win32::DriveUtils;

use strict;
use warnings;
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    GetDriveLetter
    ConnectDrive
    DisconnectDrive
);

###############################################################################
=pod

---+++ GetDriveLetter($path)
Get drive letter.

=cut
###############################################################################

sub GetDriveLetter {
    my $path = shift;
    return uc(($path =~ /^(\w):/)[0]);
}

###############################################################################
=pod

---+++ ConnectDrive($path)
Connect network drive.
=$path= can be a complete path or a drive letter.
Drive host must be set in =RJK_NETWORK_DRIVE_HOST= environment variable.

=cut
###############################################################################

sub ConnectDrive {
    my $path = shift;
    my $host = $ENV{RJK_NETWORK_DRIVE_HOST} || die "Environment variable RJK_NETWORK_DRIVE_HOST not set";

    my $drive = $path;
    unless ($path =~ /^\w$/) {
        $drive = GetDriveLetter($path) || return;
    }

    return if -e "$drive:";

    !system "net use $drive: \\\\$host\\$drive\$";
}

###############################################################################
=pod

---+++ DisconnectDrive($path)
Disconnect network drive.
=$path= can be a complete path or a drive letter.

=cut
###############################################################################

sub DisconnectDrive {
    my $path = shift;

    my $drive = $path;
    unless ($path =~ /^\w$/) {
        $drive = GetDriveLetter($path) || return;
    }

    return if !-e "$drive:";

    !system "net use /delete $drive:";
}

1;
