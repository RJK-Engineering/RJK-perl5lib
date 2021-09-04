package TBM::Relation;
use parent 'TBM::Object';

use strict;
use warnings;

sub head {
    #~ TBM::Store->fetch($_[0]{head_class}, $_[0]{head_id});
    ::table($_[0]{head_class})->get($_[0]{head_id});
}

sub tail {
    #~ TBM::Store->fetch($_[0]{tail_class}, $_[0]{tail_id});
    ::table($_[0]{tail_class})->get($_[0]{tail_id});
}

sub setHead {
    $_[0]{head_class} = $_[1]{class};
    $_[0]{head_id} = $_[1]{id};
}

sub setTail {
    $_[0]{tail_class} = $_[1]{class};
    $_[0]{tail_id} = $_[1]{id};
}

1;
