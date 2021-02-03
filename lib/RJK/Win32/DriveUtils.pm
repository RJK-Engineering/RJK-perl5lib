###############################################################################
=begin TML

---+ package RJK::Win32::DriveUtils

=cut
###############################################################################

package RJK::Win32::DriveUtils;

use strict;
use warnings;

###############################################################################
=pod

---++ Class methods

---+++ connectDrive($path)
    * =$path= - path to take drive from.

Connect network drive.
Drive host must be set in =RJK_NETWORK_DRIVE_HOST= environment variable.

=cut
###############################################################################

sub connectDrive {
    my $path = shift;
    my $host = $ENV{RJK_NETWORK_DRIVE_HOST} || die "Environment variable RJK_NETWORK_DRIVE_HOST not set";
    my $drive = ($path =~ /^(\w):/)[0] or return;
    ! system "net use $drive: \\\\$host\\$drive\$";
}

###############################################################################
=pod

---+++ disconnectDrive($path)
    * =$path= - path to take drive from.

Disconnect network drive.

=cut
###############################################################################

sub disconnectDrive {
    my $path = shift;
    my $drive = ($path =~ /^(\w):/)[0] or return;
    ! system "net use /delete $drive:";
}

1;
