package RJK::IO::File;

use strict;
use warnings;

use RJK::File::Paths;
use RJK::File::Stat;

sub new {
    my $self = bless {}, shift;
    my ($parent, $child) = @_;

    if (ref $parent && defined $child) {
        $self->{path} = RJK::File::Paths::get($parent->{path}, $child)->{path};
    } else {
        $self->{path} = RJK::File::Paths::get(@_)->{path};
    }

    return $self;
}

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
    open my $fh, '>', $_[0]{path} or die "$!: $_[0]{path}";
    close $fh;
}

sub delete {
    if ($_[0]->isFile) {
        unlink $_[0]{path} or die "$!: $_[0]{path}";
    } elsif ($_[0]->isDir) {
        rmdir $_[0]{path} or die "$!: $_[0]{path}";
    }
}

sub filenames {
    my ($self, $filter) = @_;

    opendir my $dh, $self->{path} or die "$!: $self->{path}";
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
    my $dir = $_[0]->toPath->{dir};
    $dir ? __PACKAGE__->new($dir) : undef;
}

sub stat {
    RJK::File::Stat::get($_[0]{path});
}

sub toPath {
    RJK::File::Paths::get($_[0]{path});
}

sub toString {
    $_[0]{path};
}

1;
