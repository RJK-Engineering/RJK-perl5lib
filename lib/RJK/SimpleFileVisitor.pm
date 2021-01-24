package RJK::SimpleFileVisitor;
use parent 'RJK::FileVisitor';

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my %opts = &getOpts;
    for (qw(preVisitDir postVisitDir preVisitFiles postVisitFiles visitFile visitFileFailed)) {
        $self->{$_} = $opts{$_} || sub {};
    }
    return $self;
}

sub getOpts {
    my %opts;
    if (@_ == 1) {
        if (ref $_[0] eq 'CODE') {
            $opts{visitFile} = $_[0];
        } elsif (ref $_[0] eq 'HASH') {
            %opts = %{$_[0]};
        }
    } elsif (@_ % 2 == 0) {
        %opts = @_;
    }
    return %opts;
}

sub preVisitDir {
    my $self = shift;
    $self->{preVisitDir}->(@_);
}

sub postVisitDir {
    my $self = shift;
    $self->{postVisitDir}->(@_);
}
sub preVisitFiles {
    my $self = shift;
    $self->{preVisitFiles}->(@_);
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
