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
    $_[1] =~ s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'egr;
}

###############################################################################
=pod

---+++ findPath(@paths) -> $path
Find first existing path.
With environment variable substitution.

=cut
###############################################################################

sub findPath {
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

---+++ findLocalFile($relativeFilePath) -> $path
Find file stored in local data directory =$ENV{LOCALAPPDATA}= or
=$ENV{APPDATA}= (in order of precedence).
   * =$relativeFilePath= - path to file relative to local data directory

=cut
###############################################################################

sub findLocalFile {
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

---+++ findProgramDir($relativeDirPath) -> $path
Find program directory.

=cut
###############################################################################

sub findProgramDir {
    my $relativeDirPath = shift;

    my $path = "$ENV{ProgramW6432}/$relativeDirPath";
    return $path if -e $path;

    $path = "$ENV{ProgramFiles}/$relativeDirPath";
    return $path if -e $path;
}

1;
