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

sub GetPid {
    my $pid = shift;
    my ($header, $fields);
    _GetList(sub {
        ($header, $fields) = @_;
        $fields->{PID} == $pid || undef $fields;
    });
    return $fields;
}

sub ProcessExists {
    my $procName = shift;
    return @{GetProcessList($procName)};
}

sub GetProcessList {
    my $procNameRegex = shift // ".";
    my @list;

    _GetList(sub {
        my ($header, $fields) = @_;
        return if $fields->{ImageName} !~ /$procNameRegex/;

        push @list, $fields;
        return;
    });

    return wantarray ? @list : \@list;
}

sub _GetList {
    my $callback = shift;
    my @header;

    foreach (`tasklist /v /fo csv`) {
        chomp;
        s/^"//;
        s/"$//;
        my @fields = split /","/;

        unless (@header) {
            #~ @header = @fields;
            @header = map { s/\s+//gr } @fields;
            next;
        }

        my %hash;
        @hash{@header} = @fields;

        last if $callback->(\@header, \%hash);
    }
}

1;
