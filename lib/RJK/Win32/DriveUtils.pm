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

---++ Class methods

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
    * =$path= - complete path or drive letter.

Connect network drive.
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
    * =$path= - complete path or drive letter.

Disconnect network drive.

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
