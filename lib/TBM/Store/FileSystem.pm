package TBM::Store::FileSystem;
use parent 'TBM::Store';

use strict;
use warnings;

use File::Spec::Functions qw(catdir);

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{contentRoot} = $opts{contentRoot};
    $self->{unfiledDir} = $opts{unfiledDir};
    $self->{metadataDir} = $opts{metadataDir};
    return $self;
}

sub createObject {
    my ($self, $class, $id) = @_;
    return $class->new();
}

sub fetchObject {
    my ($self, $class, $id, $properties) = @_;
}

sub fetchObjectByPath {
    my ($self, $class, $path, $properties) = @_;
    $path = catdir($self->{contentRoot}, $path);
    #~ if ($path !~ m|^/|) {
    #~     $path = $self->{unfiledDir};
    #~ } else {
    #~ }
    return -e $path && $class->new(path => $path);
}

sub getObject {
    my ($self, $class, $id) = @_;
}

sub getObjectByPath {
    my ($self, $class, $path) = @_;
}

# result sets

sub selectAll {
    my ($self, $class, $filter) = @_;
}

sub query {
    my ($self, $query) = @_;
    return "Exception(This store does not support queries)";
}

1;
