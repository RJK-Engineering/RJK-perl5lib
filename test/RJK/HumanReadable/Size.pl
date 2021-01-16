use strict;
use warnings;

use RJK::HumanReadable::Size;

my @nrs = (
1,
10,
999,
1000,
1023,
1024,
1025,
1024 * 10,
1024 * 1000 - 1024/2 - 1,
1024 * 1000 - 1024/2,
1024 * 1000 - 1,
1024 * 1000,
1024 * 1024 - 1,
1024 * 1024,
1024 * 1024 * 1.049999,
1024 * 1024 * 1.05,
1024 * 1024 * 1.1 - 1,
1024 * 1024 * 1.1,
1024 * 1024 * 1024 - 537,
1024 * 1024 * 1024 - 1,
1024 * 1024 * 1024,
1024 * 1024 * 1024 + 1,
);

printf "%10s %6s %5s %7s\n", "%10u", "%6s", "%5s", "%7.2f";

foreach (@nrs) {
    $RJK::HumanReadable::Size::precision = 4;

    my $hr = RJK::HumanReadable::Size->get($_);

    printf "%10u %6s %5s %7.2f %s %s\n", $_, $hr,
        $RJK::HumanReadable::Size::number,
        $RJK::HumanReadable::Size::exact,
        $RJK::HumanReadable::Size::exact,
        $RJK::HumanReadable::Size::symbol;
}
