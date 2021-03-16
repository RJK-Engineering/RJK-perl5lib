package RJK::HumanReadable::Size;

use strict;
use warnings;

our @symbols = qw(b K M G T P E Z Y);
our $precision = 3;
our ($number, $symbol, $exact);

sub get {
    my $self = shift;
    $exact = shift // return "";

    if ($exact < 1024) {
        $number = $exact;
        $symbol = $symbols[0];
    } else {
        my $si = 0;
        do {
            $exact /= 1024;
            $si++;
            $number = int $exact;
        } while (length $number > 3);

        my $z = $exact == $number ? ".000000" : "000000";
        $number = substr($exact.$z, 0, $precision+1) =~ s/\.$//r;
        $symbol = $symbols[$si] // "?";
    }
    return $number.$symbol;
}

1;
