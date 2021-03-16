package RJK::FileVisitor::StatsWrapper;
use parent 'RJK::FileVisitor';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{visitor} = shift;
    $self->{stats} = shift;
    return $self;
}

sub preVisitDir {
    my $self = shift;
    $self->{stats}->preVisitDir(@_);
    $self->{visitor}->preVisitDir(@_);
}

sub postVisitDir {
    my $self = shift;
    $self->{visitor}->postVisitDir(@_);
}

sub preVisitFiles {
    my $self = shift;
    $self->{visitor}->preVisitFiles(@_);
}

sub postVisitFiles {
    my $self = shift;
    $self->{visitor}->postVisitFiles(@_);
}

sub visitFile {
    my $self = shift;
    $self->{stats}->visitFile(@_);
    $self->{visitor}->visitFile(@_);
}

sub visitFileFailed {
    my $self = shift;
    $self->{stats}->visitFileFailed(@_);
    $self->{visitor}->visitFileFailed(@_);
}

1;
