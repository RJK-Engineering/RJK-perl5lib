=begin TML

---+ package RJK::TotalCmd::DiskDirFile

=cut

package RJK::TotalCmd::DiskDirFile;
use parent 'RJK::IO::File';

use v5.16; # enables fc feature
use strict;
use warnings;

use Date::Parse ();

###############################################################################
=pod

---++ Object attributes

Return object attribute value if called with no arguments, set object
attribute value and return the same value otherwise.

---+++ root($root) -> $root
---+++ directories(\@directories) -> \@directories
---+++ files(\%files) -> \%files
---+++ isDirty($isDirty) -> $isDirty

=cut
###############################################################################

use Class::AccessorMaker {
    root => undef,     # path
    directories => [], # [reldirpath,0,date,time,"",id]
    files => {},       # reldirpath => filename => [filename,size,date,time,crc,id]
    isDirty => 0,
}, "no_new";

my $rootDirpath = ".";

###############################################################################
=pod

---++ Object creation

---+++ new(%attrs) -> $diskDirFile
Returns a new =RJK::TotalCmd::DiskDirFile= object.

=cut
###############################################################################

sub new {
    my $self = shift->SUPER::new(@_);
    $self->{directories} = [];
    $self->{files} = {};
    $self->{sort} = sub { fc $_[0][0] cmp fc $_[1][0] };
    return $self;
}

sub setRoot {
    my ($self, $path) = @_;
    $self->{root} = $path;
    $self->{directories} = [ [ $rootDirpath ] ];
    $self->{files}{$rootDirpath} = {};
}

sub getFiles {
    values %{$_[0]{files}{$_[1]}};
}

sub hasFile {
    my ($self, $path) = @_;
    my ($dirpath, $filename) = $self->_splitPath($path);

    return 0 if ! $dirpath
             or ! $self->{files}{$dirpath};

    return exists $self->{files}{$dirpath}{$filename};
}

sub hasDir {
    my ($self, $dirpath) = @_;
    return 0 if $dirpath !~ s/^\Q$self->{root}\E\\?//i;

    $dirpath //= $rootDirpath;
    return exists $self->{files}{$dirpath};
}

sub getFile {
    my ($self, $path) = @_;
    my ($dirpath, $filename) = $self->_splitPath($path);

    return if ! $dirpath
           or ! $self->{files}{$dirpath}
           or ! $self->{files}{$dirpath}{$filename};

    return $self->_createFile(
        $self->{files}{$dirpath}{$filename}
    );
}

sub getDir {
    my ($self, $path) = @_;
    return if $path !~ s/^\Q$self->{root}\E\\?//i;

    $path //= $rootDirpath;
    return if ! $self->{files}{$path};

    foreach my $dir (@{$self->{directories}}) {
        if ($dir->[0] eq $path) {
            return $self->_createDir($dir);
        }
    }
    return;
}

sub setFile {
    my ($self, $file) = @_;
    my ($dirpath, $filename) = $self->_splitPath($file->{path});
    return 0 if ! $dirpath;

    # check for and add parent dir
    if (! $self->{files}{$dirpath}) {
        return 0 if ! $self->setDir($file->parent->stat);
    }

    # set file
    my @file = (
        $filename, $file->{size},
        format_datetime($file->{modified}),
    );
    # optional fields crc and id
    if (exists $file->{crc}) {
        push @file, $file->{crc};
    } elsif (exists $file->{id}) {
        push @file, "";
    }
    if (exists $file->{id}) {
        push @file, $file->{id};
    }

    $self->{isDirty} = 1;
    $self->{files}{$dirpath}{$filename} = \@file;

    return 1;
}

sub setDir {
    my ($self, $file) = @_;
    my $path = $file->{path};
    return 1 if $path =~ /^\Q$self->{root}\E\\?$/i;
    return 0 if $path !~ s/^\Q$self->{root}\E\\(.+)/$1/i;

    # dir exists
    if ($self->{files}{$path}) {
        foreach (@{$self->{directories}}) {
            next if $_->[0] ne $path;
            # date
            ($_->[2], $_->[3]) = format_datetime($file->{modified});
            # optional id
            if (exists $file->{id}) {
                $_->[4] = ""; # dir has no crc
                $_->[5] = $file->{id};
            }
            last;
        }
        return 1;
    }

    # check for and add parent directories recursively
    my $parent = $file->parent();
    if (! $self->{files}{$parent->{path}}) {
        $self->setDir($parent->stat) or return 0;
    }

    $self->{isDirty} = 1;

    # add dir
    push @{$self->{directories}}, [
        $path, 0, format_datetime($file->{modified}),
        "", exists $file->{id} ? $file->{id} : ()
    ];
    $self->{files}{$path} = {};

    return 1;
}

sub deleteFile {
    my ($self, $path) = @_;
    my ($dirpath, $filename) = $self->_splitPath($path);
    return 0 if ! $dirpath;

    return 0 if ! $self->{files}{$dirpath};
    return $self->{isDirty} = defined delete $self->{files}{$dirpath}{$filename};
}

sub deleteDir {
    my ($self, $path) = @_;
    return 0 if $path !~ s/^\Q$self->{root}\E\\//i;

    $self->{directories} = [ grep {
        unless ($_->[0] !~ /^\Q$path\E/i) {
            $self->{isDirty} = defined delete $self->{files}{$_->[0]};
            0;
        }
    } @{$self->{directories}} ];
}

sub traverse {
    my ($self, %opts) = @_;
    return 0 if $opts{path} !~ s/^\Q$self->{root}\E\\//i;

    $opts{visitFile} ||= sub {};
    foreach my $dir (@{$self->{directories}}) {
        my $d = $self->_createDir($dir);
        if ($dir->[0] =~ /^\Q$opts{path}\E/i) {
            foreach (values %{$self->{files}{$dir->[0]}}) {
                #~ print "$_->[0]\n";
                my $file = $self->_createFile($_);
                $opts{visitFile}->($file);
            }
        }
    }
}

sub search {
    my ($self, $search) = @_;

    my @results;
    my @words = split /\s+/, $search;

    foreach my $dir (@{$self->{directories}}) {
        my $d = $self->_createDir($dir);
        foreach (values %{$self->{files}{$dir->[0]}}) {
            my $name = $_->[0];
            my $match = 1;
            foreach (@words) {
                $match &&= $name =~ /$_/i;
            }
            push @results, $self->_createFile($_) if $match;
        }
    }

    return @results;
}

###############################################################################
=pod

---++ File access

---+++ read([$path]) -> $diskDirFile
Read data from file. Returns false on failure, callee on success.

---+++ write([$path]) -> $diskDirFile
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub read {
    my ($self) = @_;

    open (my $fh, '<', $self->{path}) || return 0;

    my $root = <$fh>;
    chomp $root;
    $root =~ s/\\$//;
    $self->setRoot($root);
    $self->{isDirty} = 0;

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
    my ($self) = @_;
    $self->{root} || return 0;

    open (my $fh, ">", $self->{path}) || return 0;

    foreach my $dir (@{$self->{directories}}) {
        my @fields = @$dir;
        my $path = shift @fields;

        if (@fields) { # root has path only
            print $fh "$path\\\t";
            print $fh join("\t", @fields), "\n";
        } else {
            print $fh "$self->{root}\\\n";
        }

        my $files = $self->{files}{$path};
        foreach (sort { $self->{sort}->($a, $b) } values %$files) {
            print $fh join("\t", @$_), "\n";
        }
    }
    close $fh;
    $self->{isDirty} = 0;

    return $self;
}

sub _createFile {
    my ($self, $file) = @_;
    my $f = new RJK::IO::File("$self->{root}\\$file->[0]");
    $f->{size} = $file->[1];
    $f->{modified} = parse_datetime("$file->[2] $file->[3]");
    $f->{crc} = $file->[4];
    $f->{id} = $file->[5];
    return $f;
}

sub _createDir {
    my ($self, $dir) = @_;
    my $f = new RJK::IO::File("$self->{root}\\$dir->[0]");
    if ($dir->[2]) { # root does not have date/time info
        $f->{modified} = parse_datetime("$dir->[2] $dir->[3]");
    }
    $f->{id} = $dir->[5];
    return $f;
}

sub _splitPath {
    my ($self, $path) = @_;
    return 0 if $path !~ s/^\Q$self->{root}\E//i;

    my ($dirpath, $filename) = $path =~ /\\?(.*)\\([^\\]+)/;
    $dirpath ||= $rootDirpath;
    return ($dirpath, $filename);
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
