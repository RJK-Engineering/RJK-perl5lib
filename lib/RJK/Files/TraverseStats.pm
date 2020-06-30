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

__END__

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
