package RJK::File::Visitor::Wrapper;
use parent 'RJK::File::Visitor';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;
    $self->{preVisitDir} = $opts{preVisitDir} || sub {};
    $self->{postVisitDir} = $opts{postVisitDir} || sub {};
    $self->{visitFile} = $opts{visitFile} || sub {};
    $self->{visitFileFailed} = $opts{visitFileFailed}
        || sub { shift->SUPER::visitFileFailed(@_) };
    $self->{fileSkipped} = $opts{fileSkipped} || sub {};
    $self->{dirSkipped} = $opts{dirSkipped} || sub {};
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

sub visitFile {
    my $self = shift;
    $self->{visitFile}->(@_);
}

sub visitFileFailed {
    my $self = shift;
    $self->{visitFileFailed}->(@_);
}

sub fileSkipped {
    my $self = shift;
    $self->{fileSkipped}->(@_);
}

sub dirSkipped {
    my $self = shift;
    $self->{dirSkipped}->(@_);
}

1;
