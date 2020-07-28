=begin TML

---+ interface RJK::TotalCmd::Item::ButtonInterface

---+++ isSeparator() -> $boolean
==cmd= or =button= is empty.

=cut
###############################################################################

package RJK::TotalCmd::Item::ButtonInterface;

use strict;
use warnings;

sub isSeparator {
    ! $_[0]{cmd} || ! $_[0]{button};
}

1;
