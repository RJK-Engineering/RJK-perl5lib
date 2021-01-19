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

sub getByPid {
    my ($self, $pid) = @_;
    my $proc;
    _iterate(sub { $proc = shift; return 0 }, $pid, "PID");
    return $proc;
}

sub processExists {
    my ($self, $imageName) = @_;
    my $exists;
    _iterate(sub { $exists = 1; return 0 }, $imageName);
    return $exists;
}

sub getProcessList {
    my ($self, $imageName) = @_;
    my @list;
    _iterate(sub { push @list, @_ }, $imageName);
    return \@list;
}

sub getProcessHash {
    my ($self, $imageName, $key) = @_;
    $key //= "PID";
    my %hash;
    _iterate(sub { my $proc = shift; $hash{$proc->{$key}} = $proc }, $imageName);
    return \%hash;
}

sub _iterate {
    my ($callback, $value, $match) = @_;
    $match //= "ImageName";
    my $header = 1;

    my $cmd = "tasklist /v /fo csv";
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

        last unless $callback->(\%hash);
    }
}

1;
