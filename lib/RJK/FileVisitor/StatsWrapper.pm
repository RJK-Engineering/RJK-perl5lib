package RJK::FileVisitor::StatsWrapper;
use parent 'RJK::FileVisitorBase';

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
    $self->{stats}->postVisitDir(@_);
    $self->{visitor}->postVisitDir(@_);
}

sub postVisitFiles {
    my $self = shift;
    $self->{stats}->postVisitFiles(@_);
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
