###############################################################################
=begin TML

---+ package RJK::TotalCmd::DiskDirFile

=cut
###############################################################################

package RJK::TotalCmd::DiskDirFile;

use v5.16; # enables fc feature
use strict;
use warnings;

use Exceptions;
use RJK::IO::File;
use RJK::TotalCmd::DiskDirFile::DateTime;

our $dateTimeFormatter = 'RJK::TotalCmd::DiskDirFile::DateTime';

###############################################################################
=pod

---++ Constructor

---+++ new($root) -> $diskDirFile
Returns a new =RJK::TotalCmd::DiskDirFile= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    my $root = shift;
    $self->setRoot($root) if $root;
    return $self;
}

###############################################################################
=pod

---++ Object methods

---+++ root() -> $root
---+++ dirs() -> \@dirs
---+++ files() -> \%files

=cut
###############################################################################

sub root { $_[0]{dirs}[0][0] }
sub dirs { $_[0]{dirs} }
sub files { $_[0]{files} }

sub setRoot {
    my ($self, $path) = @_;
    $path =~ s/\\$//;
    $self->{dirs}[0][0] = $path;
}

sub getFiles {
    my ($self, $path) = @_;
    my @files = values %{$self->{files}{$path}};
    return wantarray ? @files : \@files;
}

sub getDirs {
    my $self = shift;
    my $dirs = $self->{dirs};
    return wantarray ? @$dirs : $dirs;
}

sub getFile {
    my ($self, $path) = @_;
    my ($dir, $file) = $self->_splitFile($path);
    return if ! $self->fileExists($dir, $file);
    return $self->{files}{$dir}{$file};
}

sub getDir {
    my ($self, $path) = @_;
    my $dir = $self->_splitDir($path);
    return if ! $self->dirExists($dir);
    $self->_getDir($dir);
}

sub _getDir {
    my ($self, $dir) = @_;
    foreach (@{$self->{dirs}}) {
        return $_ if $_->[0] eq $dir;
    }
    throw Exception("Internal error");
}

sub hasFile {
    my ($self, $path) = @_;
    return !! $self->getFile($path);
}

sub hasDir {
    my ($self, $path) = @_;
    my $dir = $self->_splitDir($path);
    return $self->dirExists($dir);
}

sub setFile {
    my ($self, $path, $stat, $includeCreationDateTime) = @_;
    my ($dir, $file) = $self->_splitFile($path);

    my $f = new RJK::IO::File($path);
    if (! $self->dirExists($dir)) {
        $self->setDir($f->parent);
    }
    $stat //= $f->stat;

    $self->{files}{$dir}{$file} = [
        $file, $stat->size,
        $dateTimeFormatter->format($stat->modified),
        $includeCreationDateTime ? $dateTimeFormatter->format($stat->created) : ()
    ];
}

sub setDir {
    my ($self, $path, $stat, $includeCreationDateTime) = @_;
    my $dir = $self->_splitDir($path)
        or throw Exception("Path not in root: $path, root: $self->{dirs}[0][0]");
    return if $dir eq $self->{dirs}[0][0];

    my $f = new RJK::IO::File($path);
    $stat //= $f->stat;

    my @modified = $dateTimeFormatter->format($stat->modified);
    my @created = $dateTimeFormatter->format($stat->created) if $includeCreationDateTime;
    if ($self->dirExists($dir)) {
        my $dir = $self->_getDir($dir);
        ($dir->[2], $dir->[3]) = @modified;
        ($dir->[4], $dir->[5]) = @created if @created;
    } else {
        my $parent = $f->parent;
        $self->{files}{$parent} or $self->setDir($parent);
        push @{$self->{dirs}}, [ $dir, 0, @modified, @created ];
        $self->{files}{$dir} = {};
    }
}

sub deleteFile {
    my ($self, $path) = @_;
    my ($dir, $file) = $self->_splitFile($path);
    return 0 if ! $self->fileExists($dir, $file);
    return delete $self->{files}{$dir}{$file};
}

sub deleteDir {
    my ($self, $path) = @_;
    my $dir = $self->_splitDir($path);
    return 0 if ! $self->dirExists($dir);
    $self->{dirs} = [ grep { $_->[0] ne $dir } @{$self->{dirs}} ];
    return delete $self->{files}{$dir};
}

###############################################################################
=pod

---+++ read($path)
Read data from file.

---+++ write($path)
Write data to file.

=cut
###############################################################################

sub read {
    my ($self, $path) = @_;
    my $file = new RJK::IO::File($path);
    my $fh = $file->open;

    my $root = <$fh>;
    chomp $root;

    $self->{dirs} = [];
    $self->{dirs}[0][0] = $root;
    $self->{files} = {};

    my $dirpath = "";
    while (<$fh>) {
        chomp;
        my @file = split /\t/;
        if ($file[0] =~ s/\\$//) {
            $dirpath = $file[0];
            push @{$self->{dirs}}, \@file;
            $self->{files}{$dirpath} = {};
        } else {
            $self->{files}{$dirpath}{$file[0]} = \@file;
        }
    }
    close $fh;

    return $self;
}

sub write {
    my ($self, $path) = @_;
    $self->{dirs}[0][0] || throw Exception("No root path set");

    my $file = new RJK::IO::File($path);
    my $fh = $file->open('>');

    foreach (@{$self->{dirs}}) {
        my @fields = @$_;
        $path = shift @fields;

        if (@fields) {
            print $fh "$path\\\t";
            print $fh join("\t", @fields), "\n";
        } else {
            # root has path only
            print $fh "$self->{dirs}[0][0]\\\n";
        }

        my $files = $self->{files}{$path};
        foreach (sort { fc $a->[0] cmp fc $b->[0] } values %$files) {
            print $fh join("\t", @$_), "\n";
        }
    }
    close $fh;
}

sub _splitFile {
    my ($self, $path) = @_;
    return () if $path !~ s/^\Q$self->{dirs}[0][0]\E//i;
    my ($dirpath, $filename) = $path =~ /\\?(.*)\\(.+)/;
    return ($dirpath || $self->{dirs}[0][0], $filename);
}

sub _splitDir {
    my ($self, $path) = @_;
    return ($path =~ /^\Q$self->{dirs}[0][0]\E\\(.*?)\\*$/i)[0] || $self->{dirs}[0][0];
}

sub fileExists {
    my ($self, $dir, $file) = @_;
    return $self->dirExists($dir) && exists $self->{files}{$dir}{$file};
}

sub dirExists {
    my ($self, $dir) = @_;
    return exists $self->{files}{$dir};
}

1;
