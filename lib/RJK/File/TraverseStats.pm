package RJK::File::TraverseStats;

use strict;
use warnings;

my @fields = qw(size files dirs failed);

sub new {
    return bless { map { $_ => 0 } @fields }, shift;
}

sub preVisitDir {
    my $self = shift;
    $self->{dirs}++;
    $self->{dirStats} = __PACKAGE__->new;
    $self->{dirStats}{dirs}++;
}

sub visitFile {
    my ($self, $file, $stat) = @_;
    $self->{files}++;
    $self->{size} += $stat->size || 0;
    $self->{dirStats}->visitFile($file, $stat) if $self->{dirStats};
}

sub visitFileFailed {
    my $self = shift;
    $self->{failed}++;
    $self->{dirStats}->visitFileFailed(@_) if $self->{dirStats};
}

sub update {
    my ($self, $stats) = @_;
    $self->{$_} += $stats->{$_} for @fields;
}

1;
