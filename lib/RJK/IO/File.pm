package RJK::IO::File;

use strict;
use warnings;

use File::Spec::Functions qw(catdir);

use RJK::File::Exceptions;
use RJK::File::Paths;
use RJK::File::Stat;

sub new {
    my $self = bless {}, shift;
    my ($parent, $child) = @_;

    if (ref $parent) {
        if (defined $child) {
            $self->{path} = catdir($parent->{path}, $child);
        } else {
            $self->{path} = $parent->{path};
        }
    } else {
        $self->{path} = RJK::File::Paths::get(@_)->{path};
    }

    return $self;
}

sub name { $_[0]->toPath->{name} }
sub path { $_[0]{path} }
sub parent { $_[0]->toPath->{dir} }
sub canExecute { -x $_[0]{path} }
sub canRead { -r $_[0]{path} }
sub canWrite { -r $_[0]{path} }
sub exists { -e $_[0]{path} }
sub isFile { -f $_[0]{path} }
sub isDir { -d $_[0]{path} }
sub fileCreated { $_[0]->stat->{created} }
sub lastModified { $_[0]->stat->{modified} }

sub createNewFile {
    return if -e $_[0]{path};
    open my $fh, '>', $_[0]{path}
        or throw RJK::File::OpenFileException(error => "$!", file => $_[0]{path}, mode => '>');
    close $fh;
}

sub delete {
    if ($_[0]->isFile) {
        unlink $_[0]{path}
            or throw RJK::File::Exception(error => "$!", file => $_[0]{path});
    } elsif ($_[0]->isDir) {
        rmdir $_[0]{path}
            or throw RJK::File::Exception(error => "$!", file => $_[0]{path});
    }
}

sub filenames {
    my ($self, $filter) = @_;

    opendir my $dh, $self->{path}
        or throw RJK::File::OpenDirException(error => "$!", file => $self->{path});
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
    RJK::File::Stat::get($_[0]{path})
        || throw RJK::File::Exception(error => "Stat failed", file => $_[0]{path});
}

sub toPath {
    RJK::File::Paths::get($_[0]{path});
}

sub open {
    my ($self, $mode) = @_;
    $mode ||= '<';
    CORE::open my $fh, $mode, $self->{path}
        or throw RJK::File::OpenFileException(error => "$!", file => $self->{path}, mode => $mode);
    return $fh;
}

sub toString {
    $_[0]{path};
}

1;
