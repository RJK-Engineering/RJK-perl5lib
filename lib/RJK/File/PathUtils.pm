###############################################################################
=begin TML

---+ package RJK::File::PathUtils

=cut
###############################################################################

package RJK::File::PathUtils;

use strict;
use warnings;
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    CompletePath
    ExtractPath
    GetPaths
    RenamedString
);

###############################################################################
=pod

---++ Class methods

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

###############################################################################
=pod

---+++ RenamedString($from, $to) -> $string
   * =$from= - path before rename, e.g: =dir/subdir1/file.ext=
   * =$to= - path after rename, e.g: =dir/subdir2/file.ext=
   * =$string= - formatted string, e.g: =dir/{subdir1 => subdir2}/file.ext=

=cut
###############################################################################

sub RenamedString {
    my ($from, $to) = @_;
    my $string;

    my @from = split m|/|, $from;
    my @to = split m|/|, $to;

    my $i = 0;
    for (; $i < @to; $i++) {
        last if $from[$i] ne $to[$i];
    }

    my $j = $#to;
    my $d = @to - @from;
    for (; $j >= 0; $j--) {
        last if $from[$j-$d] ne $to[$j];
    }

    $string = join "/", @to[0..$i-1];
    $string .= "/" if $string;

    my $f = join "/", @from[$i..$j-$d];
    my $t = join "/", @to[$i..$j];
    $string .= "{$f => $t}";

    $string .= "/" if @to[++$j..$#to];
    $string .= join "/", @to[$j..$#to];

    return $string;
}

1;
