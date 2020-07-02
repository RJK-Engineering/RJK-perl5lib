package RJK::Files::TraverseStats;

use strict;
use warnings;

sub new {
    return bless {
        preVisitDir => 0,
        postVisitDir => 0,
        postVisitFiles => 0,
        visitFile => 0,
        visitFileFailed => 0,
        size => 0,
        files => 0,
        dirs => 0,
    }, shift;
}

sub preVisitDir {
    my $self = shift;
    $self->{preVisitDir}++;

    $self->{files} += @{$_[2]};
    $self->{dirs} += @{$_[3]};

    $self->{dirStats} = __PACKAGE__->new;
    $self->{dirStats}{files} = @{$_[2]};
    $self->{dirStats}{dirs} = @{$_[3]};
}

sub postVisitDir {
    my $self = shift;
    $self->{postVisitDir}++;
}

sub postVisitFiles {
    my $self = shift;
    $self->{postVisitFiles}++;
}

sub visitFile {
    my ($self, $file, $stat) = @_;

    $self->{visitFile}++;
    $self->{size} += $stat->{size};

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

1;
