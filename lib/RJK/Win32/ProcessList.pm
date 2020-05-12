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
    my $procNameRegex = shift // ".";
    my @list;

    _GetList(sub {
        my $values = shift;
        return if $values->{ImageName} !~ /$procNameRegex/;

        push @list, $values;
        return;
    });

    return \@list;
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

        last if $callback->(\%hash);
    }
}

1;
