package RJK::File::TraverseStats;
use parent 'RJK::File::DirStats';

use strict;
use warnings;

use Class::AccessorMaker {
    #~ visited => new RJK::File::DirStats,
    level => 0,
    timer => 0,
    timerStart => undef,
    skipped => new RJK::File::DirStats,
    visitedInDir => new RJK::File::DirStats,
    skippedInDir => new RJK::File::DirStats,
    failed => [],       # { file => RJK::IO::File,
                        #   error => "" }
    filesSkipped => [], # RJK::IO::File
    dirsSkipped => [],  # RJK::IO::File
}, "new_init";

sub init {
    my $self = shift;
    #~ $self->{visited} = new RJK::File::DirStats;
    $self->{level} = 0;
    $self->{timer} = 0;
    $self->{skipped} = new RJK::File::DirStats;
    $self->{visitedInDir} = new RJK::File::DirStats;
    $self->{skippedInDir} = new RJK::File::DirStats;
}

use Time::HiRes qw( gettimeofday tv_interval );

sub startTraverse {
    my $self = shift;
    $self->{timerStart} = [gettimeofday];

}

sub stopTraverse {
    my $self = shift;
    $self->{timerStart} || return;
    $self->{timer} += tv_interval $self->{timerStart}, [gettimeofday];
    $self->{timerStart} = undef;
}

sub time {
    my $self = shift;
    if ($self->{timerStart}) {
        return $self->{timer} + tv_interval $self->{timerStart}, [gettimeofday];
    } else {
        return $self->{timer};
    }
}

1;
