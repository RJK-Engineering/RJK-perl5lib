package RJK::Media::MPC::MPCMonUtils;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{mpcMon} = shift;
    return $self;
}

sub getMediaFile {
    my ($self, $snapshot) = @_;

    return $snapshot->{mediaFile} if $snapshot->{mediaFile};

    my $mediaFile = {};
    my $mediaFilename = $snapshot->{mediaFilename};
    my $process = $self->getProcess($mediaFilename);

    if ($process) {
        $snapshot->{process} = $process;
        $mediaFile->{path} = $process->{WindowTitle};
    } else {
        print "$mediaFilename not playing\n";
        $mediaFile->{path} = $self->findFileInDirHistory($mediaFilename);
    }

    if ($mediaFile->{path}) {
        $mediaFile->{dir} = $mediaFile->{path} =~ s/[\\\/]+[^\\\/]+$//r;
        $self->addToDirHistory($mediaFile->{dir});
    }

    $mediaFile->{name} = $mediaFilename;

    return $snapshot->{mediaFile} = $mediaFile;
}

sub getStatus {
    my ($self, $snapshot) = @_;

    my $status = $snapshot->{status};
    $status = $self->{mpcMon}->getPlayerStatus() if ! $status;

    return $snapshot->{status} = $status;
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
