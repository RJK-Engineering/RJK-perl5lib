###############################################################################
=begin TML

---+ package RJK::Env

=cut
###############################################################################

package RJK::Env;

use strict;
use warnings;

###############################################################################
=pod

---+++ subst($string) -> $newString

=cut
###############################################################################

sub subst {
    shift;
    map {
        if (ref) {
            $$_ =~ s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'eg;
        } else {
            s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'egr;
        }
    } @_;
}

###############################################################################
=pod

---+++ findPath(@paths) -> $path
Find first existing path.
With environment variable substitution.

=cut
###############################################################################

sub findPath {
    shift;
    my @paths = @_;
    my $path;
    foreach (@paths) {
        s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'eg;
        next unless -e;
        $path = $_;
        last;
    }
    return $path;
}

###############################################################################
=pod

---+++ findLocalFiles($relativeFilePath) -> @paths
   * =$relativeFilePath= - path to file relative to local data directory
   * =@paths= - list of existing paths

Find files stored in local data directories:
   * APPDATA
   * LOCALAPPDATA
   * Subdirectory "RJK-utils" of LOCALAPPDATA

=cut
###############################################################################

sub findLocalFiles {
    my ($self, $relativeFilePath) = @_;
    my @paths = (
        $ENV{APPDATA},      # roaming conf
        $ENV{LOCALAPPDATA}, # local conf
        "$ENV{LOCALAPPDATA}/RJK-utils"
    );
    return grep { -e ($_ = "$_/$relativeFilePath") } @paths;
}

###############################################################################
=pod

---+++ findProgramDirs($relativeDirPath) -> @paths
Find program directory.

=cut
###############################################################################

sub findProgramDirs {
    my ($self, $relativeDirPath) = @_;
    my @paths = (
        $ENV{ProgramW6432},
        $ENV{ProgramFiles},
    );
    return grep { -e ($_ = "$_/$relativeDirPath") } @paths;

}

1;
