package Media::TimeFormat;

use strict;
use warnings;

sub humanReadableFormat {
    my $s = shift;

    my $years = int $s / 31536000;
    $s -= $years * 31536000;
    my $days = int $s / 86400;
    $s -= $days * 86400;
    my $hours = int $s / 3600;
    $s -= $hours * 3600;
    my $mins = int $s / 60;
    $s -= $mins * 60;

    return sprintf("%uy %ud %u:%02u:%02u", $years, $days, $hours, $mins, $s)
        if $years;
    return sprintf("%ud %u:%02u:%02u", $days, $hours, $mins, $s)
        if $days;
    return sprintf("%u:%02u:%02u", $hours, $mins, $s)
        if $hours;
    return sprintf("%u:%02u", $mins, $s)
        if $mins;
    return sprintf("0:%04.1f", $s) # one decimal the time contains a fraction of a second
        if $s != int $s;
    return sprintf("0:%02u", $s);
}

1;
