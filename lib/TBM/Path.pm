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

sub setFile {
    $_[0]->SUPER::setHead($_[1]);
}

sub setDir {
    $_[0]->SUPER::setTail($_[1]);
}

sub setFilename {
    $_[0]{filename} = $_[1];
}

1;
