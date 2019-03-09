package File::AltStat;

use strict;
use warnings;

use DateTime::Format::Strptime;

my $time_zone = 'Europe/Amsterdam';
my $dtParser = DateTime::Format::Strptime->new(
    pattern => '%d-%m-%Y %H:%M',
    on_error => sub {die},
    time_zone => $time_zone
);

# alternative stat
sub stat {
    my ($file) = @_;
    my $cmd = "cmd /c dir /n /-c /4";

    my $found = 0;
    # date created & size
    foreach (`$cmd /t:C "$file->{path}"`) {
        if (/^(\d+-\d+-\d+)\s+(\d+:\d+)\s+(\d+)\s/) {
            return if $found;
            $file->{created} = "$1 $2";
            $file->{size} = $3;
            $found = 1;
        }
    }
    return unless $found;

    ConvertDate(\$file->{created});
    $found = 0;

    # date accessed
    foreach (`$cmd /t:A "$file->{path}"`) {
        if (/^(\d+-\d+-\d+)\s+(\d+:\d+)\s+\d+\s/) {
            return if $found;
            $file->{accessed} = "$1 $2";
            $found = 1;
        }
    }

    ConvertDate(\$file->{accessed});
    $found = 0;

    # date modified
    foreach (`$cmd /t:W "$file->{path}"`) {
        if (/^(\d+-\d+-\d+)\s+(\d+:\d+)\s+\d+\s/) {
            return if $found;
            $file->{modified} = "$1 $2";
            $found = 1;
        }
    }

    ConvertDate(\$file->{modified});
    $file->{exists} = 1;

    return 1;
}

sub ConvertDate {
    my $dateRef = shift;
    # this package sucks, again failure, dies despite of on_error = 'undef', so eval..
    my $dt = eval { $dtParser->parse_datetime($$dateRef) } || return;
    $$dateRef = $dt->epoch;
}

1;
