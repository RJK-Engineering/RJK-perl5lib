package TBM::Object;

use strict;
use warnings;

sub save {
    if ($_[0]{create}) {
        print " insert ".(ref $_[0])."\n";
        ::table(ref $_[0])->insert($_[0]);
    } else {
        print " update ".(ref $_[0])."\n";
        ::table(ref $_[0])->update($_[0]);
    }
}

1;
