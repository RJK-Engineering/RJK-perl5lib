package RJK::Win32::ProcessList;

use strict;
use warnings;

our @fields = qw(
    ImageName
    PID
    SessionName
    SessionNr
    MemUsage
    Status
    UserName
    CPUTime
    WindowTitle
);

my $taskListExecutable = "tasklist.exe";

sub getByPid {
    my ($self, $pid) = @_;
    my $proc;
    findProcesses($pid, sub { $proc = shift; return 0 }, "PID");
    return $proc;
}

sub processExists {
    my ($self, $imageName) = @_;
    my $exists;
    findProcesses($imageName, sub { $exists = 1; return 0 });
    return $exists;
}

sub getProcessList {
    my ($self, $imageName) = @_;
    return findProcesses($imageName);
}

sub getProcessHash {
    my ($self, $imageName, $key) = @_;
    $key //= "PID";
    my %hash;
    findProcesses($imageName, sub { my $proc = shift; $hash{$proc->{$key}} = $proc });
    return \%hash;
}

sub findProcesses {
    my ($value, $callback, $match) = @_;
    $match //= "ImageName";
    my @list;
    my $header = 1;

    my $cmd = "$taskListExecutable /v /fo csv";
    $cmd .= " /fi \"$match eq $value\"" if defined $value;

    foreach (`$cmd`) {
        if ($header) {
            $header = 0;
            next;
        }

        chomp;
        s/^"//;
        s/"$//;

        my @values = split /","/;
        my %hash;
        @hash{@fields} = @values;

        if ($callback) {
            last unless $callback->(\%hash);
        } else {
            push @list, \%hash;
        }
    }
    return \@list;
}

sub ignore {
    my ($self, $process) = @_;
    return $process->{ImageName} eq $taskListExecutable;
}

1;
