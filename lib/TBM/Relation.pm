package TBM::Relation;
use parent 'TBM::Object';

use strict;
use warnings;

sub head {
    ::table($_[0]{head_class})->get($_[0]{head_id});
}

sub tail {
    ::table($_[0]{tail_class})->get($_[0]{tail_id});
}

1;
