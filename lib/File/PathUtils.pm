=begin TML

---+ package File::PathUtils

=cut

package File::PathUtils;

use strict;
use warnings;
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    CompletePath
    ExtractPath
    GetPaths
);

###############################################################################
=pod

---+++ CompletePath($partialPath)
Returns existing file path starting with =$partialPath=.
Returns first read entry if multiple file paths are found.
Returns =undef= if no file paths are found.

=cut
###############################################################################

sub CompletePath {
    my $path = shift;
    return $path if -e $path;

    $path =~ s/[\\\/]+$//;
    my ($dir, $file) = $path =~ /(.*)(?:[\\\/](.*))/;
    return if ! -d $dir;

    $dir .= "\\";
    $path = undef;

    opendir my $dh, $dir or die "$!";
    foreach (readdir $dh) {
        next unless /^$file/i;
        $path = "$dir$_";
        last;
    }
    closedir $dh;

    return $path;
}

###############################################################################
=pod

---+++ ExtractPath($string) -> $path

Extract an absolute windows or unix path. Fixes slashes.

=cut
###############################################################################

sub ExtractPath {
    my $str = shift;
    my $s = '[\\\/]'; # slashes separating dir and file names
    my $n = '[^\?\*:|"<>\\\/]'; # not allowed in names
    my $p;
    if ($str =~ m|\b( \w: (?: $s+ $n+)* $s* )|x) {
        # win
        $p = $1;
        $p =~ s/$s+/\\/g;
    } elsif ($str =~ m|( /+ (?: $n+ /+)* $n* )|x) {
        # unix
        $p = $1;
        $p =~ s|/+|/|g;
    }
    return $p;
}

###############################################################################
=pod

---+++ GetPaths($opts) -> @paths or \@paths

Get paths from option hash.

Options (first found will be returned):
   1. file - single path
   2. dir - single path
   3. path - single path
   4. paths - reference to array of paths
   5. listFile - path to list file to read from
   6. listFiles - reference to array of paths to list files to read from

A list file contains a list of paths, one per line.

=cut
###############################################################################

sub GetPaths {
    my $opts = shift;

    my @paths;
    @paths = @{$opts->{paths}} if $opts->{paths};
    @paths = ($opts->{path}) if $opts->{path};
    @paths = ($opts->{dir}) if $opts->{dir};
    @paths = ($opts->{file}) if $opts->{file};

    if (! @paths) {
        my @listFiles;
        @listFiles = @{$opts->{listFiles}} if $opts->{listFiles};
        @listFiles = ($opts->{listFile}) if $opts->{listFile};

        my $fh;
        foreach (@listFiles) {
            open $fh, '<', $_ or die "$!";
            map { chomp; push @paths, $_ } <$fh>;
        }
        close $fh if $fh;
    }

    return wantarray ? @paths : \@paths;
}

1;
