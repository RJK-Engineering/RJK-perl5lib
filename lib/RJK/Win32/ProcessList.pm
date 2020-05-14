package RJK::Win32::ProcessList;

use strict;
use warnings;
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    GetByPid
    ProcessExists
    GetProcessList
);
our %EXPORT_TAGS = (ALL => \@EXPORT_OK);

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

sub GetByPid {
    my $pid = shift;
    my $values;
    _GetList(sub {
        $values = shift;
    }, $pid, "PID");
    return $values;
}

sub ProcessExists {
    my $imageName = shift;
    return @{GetProcessList($imageName)};
}

sub GetProcessList {
    my $imageName = shift;
    my @list;

    _GetList(sub {
        my $values = shift;
        return push @list, $values;
    }, $imageName);

    return \@list;
}

sub GetProcessHash {
    my ($imageName, $key) = @_;
    $key //= "PID";
    my %hash;

    _GetList(sub {
        my $values = shift;
        $hash{$values->{$key}} = $values;
    }, $imageName);

    return \%hash;
}

sub _GetList {
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
