###############################################################################
=begin TML

---+ package RJK::File::PathFinder
Find paths to files.

=cut
###############################################################################

package RJK::File::PathFinder;

use strict;
use warnings;

###############################################################################
=pod

---++ FindPath(@paths) -> $path
Find first existing path.
With environment variable substitution.

=cut
###############################################################################

sub FindPath {
    my @paths = @_;
    my $path;
    foreach (@paths) {
        s|%(\w+)%|$ENV{$1}//''|ge;
        next unless -e;
        $path = $_;
        last;
    }
    return $path;
}

###############################################################################
=pod

---+++ FindLocalFile($relativeFilePath) -> $path
Find file stored in local data directory =$ENV{LOCALAPPDATA}= or
=$ENV{APPDATA}= (in order of precedence).
   * =$relativeFilePath= - path to file relative to local data directory

=cut
###############################################################################

sub FindLocalFile {
    my $relativeFilePath = shift;

    # local conf, overrules roaming conf
    my $path = "$ENV{LOCALAPPDATA}/$relativeFilePath";
    return $path if -e $path;

    # roaming conf
    $path = "$ENV{APPDATA}/$relativeFilePath";
    return $path if -e $path;
}

###############################################################################
=pod

---+++ FindProgramDir($relativeDirPath) -> $path
Find program directory.

=cut
###############################################################################

sub FindProgramDir {
    my $relativeDirPath = shift;

    my $path = "$ENV{ProgramW6432}/$relativeDirPath";
    return $path if -e $path;

    $path = "$ENV{ProgramFiles}/$relativeDirPath";
    return $path if -e $path;
}

1;
