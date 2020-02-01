package TBM::FileObject;
#~ use parent 'TBM::IdObject';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{path} = $opts{path};
    return $self;
}

sub setName {
    my ($self, $name) = @_;
    $self->{name} = $name;
}

sub getName {
    my $self = shift;
    return $self->{name};
}

# interface Persistable

sub delete {
    my $self = shift;
}

sub save {
    my $self = shift;
}

sub refresh {
    my ($self, $properties) = @_;
}

1;
