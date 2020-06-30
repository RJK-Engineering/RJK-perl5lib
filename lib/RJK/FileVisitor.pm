package RJK::FileVisitor;
use parent 'RJK::FileVisitorBase';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    for (qw(preVisitDir postVisitDir postVisitFiles visitFile visitFileFailed)) {
        $self->{$_} = $opts{$_} || sub {};
    }
    return $self;
};

sub preVisitDir {
    my $self = shift;
    $self->{preVisitDir}->(@_);
}

sub postVisitDir {
    my $self = shift;
    $self->{postVisitDir}->(@_);
}

sub postVisitFiles {
    my $self = shift;
    $self->{postVisitFiles}->(@_);
}

sub visitFile {
    my $self = shift;
    $self->{visitFile}->(@_);
}

sub visitFileFailed {
    my $self = shift;
    $self->{visitFileFailed}->(@_);
}

1;
