package RJK::Win32::ProcessList;

use strict;
use warnings;
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    GetPid
    ProcessExists
    GetProcessList
);

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

sub GetPid {
    my $pid = shift;
    my $values;
    _GetList(sub {
        $values = shift;
        $values->{PID} == $pid || undef $values;
    });
    return $values;
}

sub ProcessExists {
    my $procName = shift;
    return @{GetProcessList($procName)};
}

sub GetProcessList {
    my $procNameRegex = shift;
    my $match = shift // "ImageName";
    my @list;

    _GetList(sub {
        my $values = shift;
        return 1 if $procNameRegex && $values->{$match} !~ /$procNameRegex/;
        return push @list, $values;
    });

    return \@list;
}

sub GetProcessHash {
    my $procNameRegex = shift;
    my $match = shift // "ImageName";
    my $key = shift // "PID";
    my %hash;

    _GetList(sub {
        my $values = shift;
        return 1 if $procNameRegex && $values->{$match} !~ /$procNameRegex/;
        return $values->{$key} = $values;
    });

    return \%hash;
}

sub _GetList {
    my $callback = shift;
    my $header = 1;

    foreach (`tasklist /v /fo csv`) {
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
