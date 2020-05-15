package RJK::Media::MPC::MPCMonUtils;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{mpcMon} = shift;
    return $self;
}

# Get status and path info for media file
sub retrieveStatusInfo {
    my ($self, $object, $mediaFilename) = @_;

    # first Observer sets status
    return if $object->{status};

    my $status = $object->{status} = {};

    my $process = $self->getProcess($mediaFilename);
    if ($process) {
        $status->{process} = $process;
        $status->{mediaFilePath} = $process->{WindowTitle};
    } else {
        print "$mediaFilename not playing\n";
        $status->{mediaFilePath} = $self->findFileInDirHistory($mediaFilename);
    }

    $status->{mpc} = $self->{mpcMon}->getPlayerStatus();
    if ($status->{mpc}{file} && $status->{mpc}{file} eq $mediaFilename) {
        if (! $status->{mediaFilePath}) {
            $status->{mediaFilePath} = $status->{mpc}{filepath};
            $status->{mediaFileDir} = $status->{mpc}{filedir};
        } elsif ($status->{mediaFilePath} ne $status->{mpc}{filepath}) {
            print "WARN Path mismatch: $status->{mediaFilePath}\n";
            print "WARN Path mismatch: $status->{mpc}{filepath}\n";
        }
    }

    $status->{mediaFilePath} || return;

    if (! $status->{mediaFileDir}) {
        $status->{mediaFileDir} = $status->{mediaFilePath} =~ s/[\\\/]+[^\\\/]+$//r;
    }
    $self->addToDirHistory($status->{mediaFileDir}) if $status->{mediaFileDir};
}

sub getProcess {
    my ($self, $windowTitle) = @_;
    my $process;

    my $processList = $self->{mpcMon}->nowPlaying();
    foreach (@$processList) {
        next if $_->{WindowTitle} !~ /\Q$windowTitle\E$/;
        print "WARN Duplicate file open: $process->{WindowTitle}\n" if $process;
        $process = $_;
    }
    return $process;
}

sub findFileInDirHistory {
    my ($self, $filename) = @_;
    my $path;

    foreach (keys %{$self->{dirHistory}}) {
        my $path = "$_/$filename";
        next if !-e $path;
        print "WARN Duplicate filename: $path\n" if $path;
        $path = $_;
    }
    return $path;
}

sub addToDirHistory {
    my ($self, $path) = @_;
    $self->{dirHistory}{$path} = 1;
}

1;
