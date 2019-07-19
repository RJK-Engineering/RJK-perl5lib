package TBM::Store::FileSystem;
use parent 'TBM::Store';

use strict;
use warnings;

use File::Spec::Functions qw(catdir);

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{root} = $opts{root};
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
    $path = catdir($self->{root}, $path);
    return -e $path && $class->new(path => $path);
}

sub getObject {
    my ($self, $class, $id) = @_;
}

sub getObjectByPath {
    my ($self, $class, $path) = @_;
}

1;
