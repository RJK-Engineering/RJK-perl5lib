package TBM::Object;

use strict;
use warnings;

sub save {
    TBM::Factory->save($_[0]);
}

1;
