package RJK::TotalCmd::Item::ButtonInterface;

use strict;
use warnings;

sub isSeparator {
    ! $_[0]{cmd} || ! $_[0]{button};
}

1;
