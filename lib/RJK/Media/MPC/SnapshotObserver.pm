package RJK::Media::MPC::SnapshotObserver;
use parent 'RJK::Media::MPC::Observer';

use strict;
use warnings;

sub decoratePayload {
    my ($self, $snapshot) = @_;
    my $filename = $snapshot->{name};
    my %payload = (snapshot => $snapshot);

    my $process = $self->getProcess($filename);
    if ($process) {
        $payload{process} = $process;
        $payload{path} = $process->{WindowTitle};
    } else {
        print "$filename not playing\n";
        $payload{path} = $self->findFileInDirHistory($filename);
    }

    my $status = $self->{mpcMon}->getPlayerStatus();
    if ($status->{file}) {
        if ($status->{file} eq $filename) {
            $payload{status} = $status;
            if (! $payload{path}) {
                $payload{path} = $payload{status}{filepath};
                $payload{dir} = $payload{status}{filedir};
            } elsif ($payload{path} ne $payload{status}{filepath}) {
                print "WARN Path mismatch: $payload{path}\n";
                print "WARN Path mismatch: $payload{status}{filepath}\n";
            }
        }
    }

    $payload{path} || return;

    if (! $payload{dir}) {
        $payload{dir} = $payload{path} =~ s/[\\\/]+[^\\\/]+$//r;
    }
    $self->addToDirHistory($payload{dir}) if $payload{dir};

    return \%payload;
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
