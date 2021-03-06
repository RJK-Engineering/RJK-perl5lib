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

---++ Class methods

---+++ subst($string) -> $newString
---+++ subst(@stringsRefs)
   * =$string= - string to perform environment variable substitution on
   * =$newString= - string after environment variable substitution
   * =@stringsRefs= - list of references to strings to perform environment variable substitution on

=cut
###############################################################################

sub subst {
    shift;
    if (ref $_[0]) {
        map { $$_ =~ s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'eg } @_;
    } else {
        $_[0] =~ s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'egr;
    }
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

---+++ findLocalFiles($relativeFilePath) -> @paths or \@paths
   * =$relativeFilePath= - path to file relative to local data directory
   * =@paths= - list of existing paths

Find files in directories set in =APPDATA= and =LOCALAPPDATA=
environment variables.

=cut
###############################################################################

sub findLocalFiles {
    my ($self, $relativeFilePath) = @_;
    my @paths = ($ENV{APPDATA}, $ENV{LOCALAPPDATA});
    @paths = grep { -e ($_ = "$_/$relativeFilePath") } @paths;
    return wantarray ? @paths : \@paths;
}

###############################################################################
=pod

---+++ findProgramDirs($relativeDirPath) -> @paths or \@paths
Find program directory in directories set in =ProgramW6432=, =ProgramFiles=
and =ProgramFiles(x86)= environment variables.

=cut
###############################################################################

sub findProgramDirs {
    my ($self, $relativeDirPath) = @_;
    my %paths = (
        $ENV{ProgramW6432} => 1,
        $ENV{ProgramFiles} => 1,
        $ENV{'ProgramFiles(x86)'} => 1
    );
    my @paths = grep { -e ($_ = "$_/$relativeDirPath") } keys %paths;
    return wantarray ? @paths : \@paths;
}

1;
