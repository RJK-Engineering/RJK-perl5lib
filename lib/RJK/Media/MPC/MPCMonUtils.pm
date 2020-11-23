package RJK::Media::MPC::MPCMonUtils;

use strict;
use warnings;

use RJK::Win32::ProcessList;

sub new {
    my $self = bless {}, shift;
    $self->{controller} = shift;
    return $self;
}

sub nowPlaying {
    return RJK::Win32::ProcessList::GetProcessList("mpc-hc64.exe");
}

sub getPlayerStatus {
    my $self = shift;
    return $self->{controller}->mpcMon->getStatus();
}

sub getStatus {
    my ($self, $object) = @_;
    return $object->{mpcStatus} if $object->{mpcStatus};
    return $object->{mpcStatus} = $self->getPlayerStatus();
}

# sets and returns $object->{mediaFile} = { dir, name => $object->{$filenameKey}, path }
# $filenameKey default = mediaFilename
sub getMediaFilePath {
    my ($self, $object, $filenameKey) = @_;

    return $object->{mediaFile} if $object->{mediaFile};

    my $mediaFile = {};
    my $mediaFilename = $object->{$filenameKey // "mediaFilename"};
    my $process = $self->getProcess($mediaFilename);

    if ($process) {
        $object->{process} = $process;
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

    return $object->{mediaFile} = $mediaFile;
}

sub getProcess {
    my ($self, $windowTitle) = @_;
    my $process;

    my $processList = $self->nowPlaying();
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
