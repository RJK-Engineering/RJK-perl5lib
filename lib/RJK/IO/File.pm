package RJK::IO::File;

use strict;
use warnings;

use Exceptions;
use FileException;
use OpenDirException;
use OpenFileException;
use RJK::Path;
use RJK::Paths;
use RJK::Stat;

sub new {
    my $self = bless {}, shift;
    $_[0] = $_[0]->{path} if ref $_[0];
    $self->{path} = RJK::Paths->get(@_)->{path};
    return $self;
}

sub name { $_[0]->toPath->{name} }
sub path { $_[0]{path} }
sub parent { $_[0]->toPath->parent }
sub canExecute { -x $_[0]{path} }
sub canRead { -r $_[0]{path} }
sub canWrite { -r $_[0]{path} }
sub exists { -e $_[0]{path} }
sub isFile { -f $_[0]{path} }
sub isDir { -d $_[0]{path} }
sub fileCreated { $_[0]->stat->created }
sub lastModified { $_[0]->stat->modified }

sub createNewFile {
    return if -e $_[0]{path};
    open my $fh, '>', $_[0]{path}
        or throw OpenFileException(error => "$!: $_[0]{path}", file => $_[0]{path}, mode => '>');
    close $fh;
}

sub delete {
    if ($_[0]->isFile) {
        unlink $_[0]{path}
            or throw FileException(error => "$!: $_[0]{path}", file => $_[0]{path});
    } elsif ($_[0]->isDir) {
        rmdir $_[0]{path}
            or throw FileException(error => "$!: $_[0]{path}", file => $_[0]{path});
    }
}

sub filenames {
    my ($self, $filter) = @_;

    opendir my $dh, $self->{path}
        or throw OpenDirException(error => "$!: $self->{path}", file => $self->{path});
    my @names = readdir $dh;
    closedir $dh;

    if ($filter) {
        @names = grep { $filter->($_) } @names;
    }

    return wantarray ? @names : \@names;
}

sub files {
    my ($self, $filter) = @_;

    my @files =  map { __PACKAGE__->new($self->{path}, $_) } $self->filenames;

    if ($filter) {
        @files = grep { $filter->($_) } @files;
    }

    return wantarray ? @files : \@files;
}

sub getParentFile {
    my $dir = $_[0]->parent;
    $dir ? __PACKAGE__->new($dir) : undef;
}

sub stat {
    RJK::Stat->get($_[0]{path})
        || throw FileException(error => "Stat failed: $_[0]{path}", file => $_[0]{path});
}

sub toPath {
    RJK::Paths->get($_[0]{path});
}

sub open {
    my ($self, $mode) = @_;
    $mode ||= '<';
    CORE::open my $fh, $mode, $self->{path}
        or throw OpenFileException(error => "$!: $self->{path}", file => $self->{path}, mode => $mode);
    return $fh;
}

sub toString {
    $_[0]{path};
}

1;
