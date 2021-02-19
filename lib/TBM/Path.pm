package TBM::Path;
use parent 'TBM::Relation';

use strict;
use warnings;

sub getFile {
    $_[0]->SUPER::head();
}

sub getDir {
    $_[0]->SUPER::tail();
}

1;
