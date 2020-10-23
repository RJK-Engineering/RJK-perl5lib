package RJK::File::TraverseStats;

use strict;
use warnings;

my @fields = qw(
preVisitDir
postVisitDir
preVisitFiles
postVisitFiles
visitFile
visitFileFailed
size
files
dirs
);

sub new {
    return bless { map { $_ => 0 } @fields }, shift;
}

sub preVisitDir {
    my $self = shift;
    $self->{preVisitDir}++;

    $self->{files} += @{$_[2]} if $_[2];
    $self->{dirs} += @{$_[3]} if $_[3];

    $self->{dirStats} = __PACKAGE__->new;
    $self->{dirStats}{files} = @{$_[2]} if $_[2];
    $self->{dirStats}{dirs} = @{$_[3]} if $_[3];
}

sub postVisitDir {
    my $self = shift;
    $self->{postVisitDir}++;
}

sub preVisitFiles {
    my $self = shift;
    $self->{preVisitFiles}++;
}

sub postVisitFiles {
    my $self = shift;
    $self->{postVisitFiles}++;
}

sub visitFile {
    my ($self, $file, $stat) = @_;

    $self->{visitFile}++;
    $self->{size} += $stat->{size} || 0;

    if ($self->{dirStats}) {
        $self->{dirStats}->visitFile($file, $stat);
    }
}

sub visitFileFailed {
    my $self = shift;

    $self->{visitFileFailed}++;

    if ($self->{dirStats}) {
        $self->{dirStats}->visitFileFailed(@_);
    }
}

sub update {
    my ($self, $stats) = @_;
    $self->{$_} += $stats->{$_} for @fields;
}

1;
