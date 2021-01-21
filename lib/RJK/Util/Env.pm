package RJK::Util::Env;

use strict;
use warnings;

sub subst {
    $_[1] =~ s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'egr;
}

1;
