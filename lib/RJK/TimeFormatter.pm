package RJK::TimeFormatter;

use strict;
use warnings;

sub format {
    my ($class, $s, $precision) = @_;
    $precision //= 3;

    $s = $s->{seconds} if ref $s;
    my $sign = $s < 0 ? (($s = 0 - $s) && "-") : "";

    my $hours = int $s / 3600;
    $s -= $hours * 3600;
    my $mins = int $s / 60;
    $s -= $mins * 60;

    return $sign . ($hours ? sprintf("%u:%02u:", $hours, $mins) : "$mins:") .
        sprintf($precision ? "%0".($precision + 3).".${precision}f" : "%02u", $s);
}

1;
