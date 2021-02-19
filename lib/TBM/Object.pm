package TBM::Object;

use strict;
use warnings;

sub save {
    ::table(ref $_[0])->update($_[0]);
}

1;
