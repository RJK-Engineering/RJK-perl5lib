package RJK::Media::MPC::SnapshotObserver;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub retrieveStatus {
    my ($self, $snapshot) = @_;
    # first Observer sets status
    return if $snapshot->{status};

    my $filename = $snapshot->{mediaFilename};

    my $process = $self->getProcess($filename);
    if ($process) {
        $snapshot->{process} = $process;
        $snapshot->{mediaFilePath} = $process->{WindowTitle};
    } else {
        print "$filename not playing\n";
        $snapshot->{mediaFilePath} = $self->findFileInDirHistory($filename);
    }

    $snapshot->{status} = $self->{mpcMon}->getPlayerStatus();
    if ($snapshot->{status}{file} && $snapshot->{status}{file} eq $filename) {
        if (! $snapshot->{mediaFilePath}) {
            $snapshot->{mediaFilePath} = $snapshot->{status}{filepath};
            $snapshot->{mediaFileDir} = $snapshot->{status}{filedir};
        } elsif ($snapshot->{mediaFilePath} ne $snapshot->{status}{filepath}) {
            print "WARN Path mismatch: $snapshot->{mediaFilePath}\n";
            print "WARN Path mismatch: $snapshot->{status}{filepath}\n";
        }
    }

    $snapshot->{mediaFilePath} || return;

    if (! $snapshot->{mediaFileDir}) {
        $snapshot->{mediaFileDir} = $snapshot->{mediaFilePath} =~ s/[\\\/]+[^\\\/]+$//r;
    }
    $self->addToDirHistory($snapshot->{mediaFileDir}) if $snapshot->{mediaFileDir};
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
