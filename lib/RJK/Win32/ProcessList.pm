package RJK::Win32::ProcessList;

use strict;
use warnings;

my @fields = qw(
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
    my $pid = shift;
    my $values;
    _getList(sub {
        $values = shift;
    }, $pid, "PID");
    return $values;
}

sub processExists {
    my ($self, $imageName) = @_;
    return @{$self->getProcessList($imageName)};
}

sub getProcessList {
    my ($self, $imageName) = @_;
    my @list;

    _getList(sub {
        my $values = shift;
        return push @list, $values;
    }, $imageName);

    return \@list;
}

sub getProcessHash {
    my ($self, $imageName, $key) = @_;
    $key //= "PID";
    my %hash;

    _getList(sub {
        my $values = shift;
        $hash{$values->{$key}} = $values;
    }, $imageName);

    return \%hash;
}

sub _getList {
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
