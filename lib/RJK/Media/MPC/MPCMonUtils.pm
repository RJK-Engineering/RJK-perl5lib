package RJK::Media::MPC::MPCMonUtils;

use strict;
use warnings;

use RJK::Media::MPC::Utils::Category;
use RJK::Win32::ProcessList;

sub new {
    my $self = bless {}, shift;
    $self->{mpcMon} = shift;
    $self->{category} = new RJK::Media::MPC::Utils::Category($self->{mpcMon});
    return $self;
}

sub category {
    $_[0]{category}
}

sub nowPlaying {
    return RJK::Win32::ProcessList::GetProcessList("mpc-hc64.exe");
}

sub getPlayerStatus {
    my $self = shift;
    return $self->{mpcMon}{observables}{WebIFMonitor}->getStatus();
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
