=begin TML

---+ package RJK::TotalCmd::DiskDirFile

=cut

package RJK::TotalCmd::DiskDirFile;

use v5.16; # enables fc feature
use strict;
use warnings;

use Date::Parse ();
use Exception::Class 'Exception';

use RJK::IO::File;

my $rootDirpath = ".";

###############################################################################
=pod

---++ Object creation

---+++ new(%attrs) -> $diskDirFile
Returns a new =RJK::TotalCmd::DiskDirFile= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{root} = shift;
    return $self;
}

###############################################################################
=pod

---++ Object attributes

---+++ root($root) -> $root
---+++ directories(\@directories) -> \@directories
---+++ files(\%files) -> \%files

=cut
###############################################################################

sub root { $_[0]{root} }
sub directories { $_[0]{directories} }
sub files { $_[0]{files} }

sub setRoot {
    my ($self, $path) = @_;
    $self->{root} = $path;
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
    my ($dir, $file) = $self->_splitPath($path);
    return undef if ! $self->_fileExists($dir, $file);
    return $self->{files}{$dir}{$file};
}

sub getDir {
    my ($self, $path) = @_;
    my ($dir) = $self->_splitPath("$path\\file");
    return undef if ! $self->_dirExists($dir);
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
    my ($dir) = $self->_splitPath("$path\\file");
    return $self->_dirExists($dir);
}

sub setFile {
    my ($self, $path, $stat) = @_;
    my ($dir, $file) = $self->_splitPath($path);
    $self->_dirExists($dir)
        || throw Exception(error => "Directory not available in archive: $dir");

    $stat //= new RJK::IO::File($path)->stat;

    my @file = (
        $file, $stat->{size},
        format_datetime($stat->{modified}),
    );
    #~ # optional fields crc and id
    #~ if (exists $file->{crc}) {
    #~     push @file, $file->{crc};
    #~ } elsif (exists $file->{id}) {
    #~     push @file, "";
    #~ }
    #~ if (exists $file->{id}) {
    #~     push @file, $file->{id};
    #~ }

    $self->{files}{$dir}{$file} = \@file;

    return 1;
}

sub setDir {
    my ($self, $path, $stat) = @_;
    my $dir = new RJK::IO::File($path);
    $path = $dir->{path};
    return 1 if $path =~ /^\Q$self->{root}\E\\?$/i;
    return 0 if $path !~ s/^\Q$self->{root}\E\\(.+)/$1/i;

    $stat //= $dir->stat;

    # dir exists
    if ($self->{files}{$path}) {
        foreach (@{$self->{directories}}) {
            next if $_->[0] ne $path;
            # update stat
            ($_->[2], $_->[3]) = format_datetime($stat->{modified});
            # optional id
            #~ if (exists $dir->{id}) {
            #~     $_->[4] = ""; # dir has no crc
            #~     $_->[5] = $dir->{id};
            #~ }
            last;
        }
        return 1;
    }

    # check for and add parent directories recursively
    my $parent = $dir->parent;
    if (! $self->{files}{$parent}) {
        $self->setDir($parent) or return 0;
    }

    # add dir
    push @{$self->{directories}}, [
        $path, 0, format_datetime($stat->{modified}),
        #~ "", exists $dir->{id} ? $dir->{id} : ()
    ];
    $self->{files}{$path} = {};

    return 1;
}

sub deleteFile {
    my ($self, $path) = @_;
    my ($dir, $file) = $self->_splitPath($path);
    return 0 if ! $self->_fileExists($dir, $file);
    return delete $self->{files}{$dir}{$file};
}

sub deleteDir {
    my ($self, $path) = @_;
    my ($dir) = $self->_splitPath("$path\\file");
    return 0 if ! $self->_dirExists($dir);
    $self->{directories} = [ grep { $_->[0] ne $dir } @{$self->{directories}} ];
    return delete $self->{files}{$dir};
}

###############################################################################
=pod

---++ File access

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
    $root =~ s/\\$//;

    $self->setRoot($root);
    $self->{directories} = [ [ $rootDirpath ] ];
    $self->{files}{$rootDirpath} = {};

    my $dirpath = $rootDirpath;
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

        if (@fields) { # root has path only
            print $fh "$path\\\t";
            print $fh join("\t", @fields), "\n";
        } else {
            print $fh "$self->{root}\\\n";
        }

        my $files = $self->{files}{$path};
        foreach (sort { fc $a->[0] cmp fc $b->[0] } values %$files) {
            print $fh join("\t", @$_), "\n";
        }
    }
    close $fh;
}

sub _splitPath {
    my ($self, $path) = @_;
    return () if $path !~ s/^\Q$self->{root}\E//i;

    my ($dirpath, $filename) = $path =~ /\\?(.*)\\([^\\]+)/;
    $dirpath ||= $rootDirpath;
    return ($dirpath, $filename);
}

sub _fileExists {
    my ($self, $dir, $file) = @_;
    return $self->_dirExists($dir)
        && exists $self->{files}{$dir}{$file};
}

sub _dirExists {
    my ($self, $dir) = @_;
    return $dir && exists $self->{files}{$dir};
}

sub parse_datetime {
    my @t = split /[:\. ]/, shift;
    die if @t != 6;
    return Date::Parse::str2time(sprintf "%u:%02u:%02uT%02u:%02u:%02u", @t);
}

sub format_datetime {
    my @t = localtime shift;
    return (sprintf("%s.%s.%s", $t[5]+1900, $t[4]+1, $t[3]),
            sprintf("%s:%s.%s", $t[2], $t[1], $t[0]));
}

1;
