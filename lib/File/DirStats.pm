package File::DirStats;

use strict;
use warnings;

use Class::AccessorMaker {
    dirs => 0,
    files => 0,
    total => 0,
    size => 0,
}, "no_new";

sub new {
    my $self = bless {}, shift;
    my $stats = shift;
    $self->reset;
    $self->add($stats) if $stats;
    return $self;
}

sub clone {
    my $self = shift;
    return __PACKAGE__->new($self,
        map { $_ => $self->{$_} } keys %$self
    );
}

sub add {
    my ($self, $stats) = @_;
    $self->{$_} += $stats->{$_} || 0 for keys %$self;
    return $self;
}

sub addDir {
    my ($self) = @_;
    $self->{dirs}++;
    $self->{total}++;
    return $self;
}

sub addFile {
    my ($self, $file) = @_;
    $self->{files}++;
    $self->{total}++;
    $self->{size} += $file->{size} || 0;
    return $self;
}

sub reset {
    my ($self) = @_;
    $self->{files} =
    $self->{dirs} =
    $self->{total} =
    $self->{size} = 0;
    return $self;
}

sub toString {
    my ($self) = @_;
    return "$self->{files} files, $self->{dirs} dirs, $self->{size} bytes";
}

1;
