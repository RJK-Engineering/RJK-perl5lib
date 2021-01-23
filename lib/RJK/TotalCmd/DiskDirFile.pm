###############################################################################
=begin TML

---+ package RJK::TotalCmd::DiskDirFile

=cut
###############################################################################

package RJK::TotalCmd::DiskDirFile;

use v5.16; # enables fc feature
use strict;
use warnings;

use Time::Local 'timelocal';
use Exceptions;

use RJK::IO::File;

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
---+++ directories() -> \@directories
---+++ files() -> \%files

=cut
###############################################################################

sub root { $_[0]{root} }
sub directories { $_[0]{directories} }
sub files { $_[0]{files} }

sub setRoot {
    my ($self, $path) = @_;
    $path =~ s/\\$//;
    $self->{root} = $path;
    $self->{directories}[0][0] = $path;
}

sub getFiles {
    my ($self, $path) = @_;
    my @files = values %{$self->{files}{$path}};
    return wantarray ? @files : \@files;
}

sub getDirectories {
    my $self = shift;
    my $dirs = $self->{directories};
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
    foreach (@{$self->{directories}}) {
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
    my ($self, $path, $stat) = @_;
    my ($dir, $file) = $self->_splitFile($path);

    my $f = new RJK::IO::File($path);
    if (! $self->dirExists($dir)) {
        $self->setDir($f->parent);
    }
    $stat //= $f->stat;

    $self->{files}{$dir}{$file} = [
        $file, $stat->size,
        format_datetime($stat->modified)
    ];
}

sub setDir {
    my ($self, $path, $stat) = @_;
    my $dir = $self->_splitDir($path);
    $dir || throw Exception("Path not in root: $path, root: $self->{root}");
    return if $dir eq $self->{root};

    my $f = new RJK::IO::File($path);
    $stat //= $f->stat;

    if ($self->dirExists($dir)) {
        my $dir = $self->_getDir($dir);
        ($dir->[2], $dir->[3]) = format_datetime($stat->modified);
    } else {
        my $parent = $f->parent;
        if (! $self->{files}{$parent}) {
            # add parent directories recursively
            $self->setDir($parent);
        }

        push @{$self->{directories}}, [
            $dir, 0, format_datetime($stat->modified)
        ];
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
    $self->{directories} = [ grep { $_->[0] ne $dir } @{$self->{directories}} ];
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

    $self->{directories} = [];
    $self->setRoot($root);
    $self->{files} = {};

    my $dirpath = "";
    while (<$fh>) {
        chomp;
        my @file = split /\t/;
        if ($file[0] =~ s/\\$//) {
            $dirpath = $file[0];
            push @{$self->{directories}}, \@file;
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
    $self->{root} || throw Exception("No root path set");

    my $file = new RJK::IO::File($path);
    my $fh = $file->open('>');

    foreach (@{$self->{directories}}) {
        my @fields = @$_;
        $path = shift @fields;

        if (@fields) {
            print $fh "$path\\\t";
            print $fh join("\t", @fields), "\n";
        } else {
            # root has path only
            print $fh "$self->{root}\\\n";
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
    return () if $path !~ s/^\Q$self->{root}\E//i;
    my ($dirpath, $filename) = $path =~ /\\?(.*)\\(.+)/;
    return ($dirpath || $self->{root}, $filename);
}

sub _splitDir {
    my ($self, $path) = @_;
    return ($path =~ /^\Q$self->{root}\E\\(.*?)\\*$/i)[0] || $self->{root};
}

sub fileExists {
    my ($self, $dir, $file) = @_;
    return $self->dirExists($dir) && exists $self->{files}{$dir}{$file};
}

sub dirExists {
    my ($self, $dir) = @_;
    return exists $self->{files}{$dir};
}

sub parse_datetime {
    my @t = reverse split /[:\. ]/, shift;
    die if @t != 6;
    $t[5] -= 1900;
    $t[4]--;
    return timelocal(@t);
}

sub format_datetime {
    my @t = localtime shift;
    return (sprintf("%s.%s.%s", $t[5]+1900, $t[4]+1, $t[3]),
            sprintf("%s:%s.%s", $t[2], $t[1], $t[0]));
}

1;
