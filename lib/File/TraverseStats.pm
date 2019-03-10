package File::TraverseStats;
use parent 'File::DirStats';

use strict;
use warnings;

use Class::AccessorMaker {
    #~ visited => new File::DirStats,
    level => 0,
    timer => 0,
    timerStart => undef,
    skipped => new File::DirStats,
    visitedInDir => new File::DirStats,
    skippedInDir => new File::DirStats,
    failed => [],       # { file => File::File,
                        #   error => "" }
    filesSkipped => [], # File::File
    dirsSkipped => [],  # File::File
}, "new_init";

sub init {
    my $self = shift;
    #~ $self->{visited} = new File::DirStats;
    $self->{level} = 0;
    $self->{timer} = 0;
    $self->{skipped} = new File::DirStats;
    $self->{visitedInDir} = new File::DirStats;
    $self->{skippedInDir} = new File::DirStats;
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
