=begin TML

---+ interface RJK::TotalCmd::Item::ItemInterface

---+++ isButton() -> $boolean
==cmd= and =button= are not empty.

---+++ isCommand() -> $boolean
==cmd= is not empty.

---+++ isMenuItem() -> $boolean
==menu= is not empty.

=cut
###############################################################################

package RJK::TotalCmd::Item::ItemInterface;

use strict;
use warnings;

sub isButton {
    !! ($_[0]{cmd} && $_[0]{button});
}

sub isCommand {
    !! $_[0]{cmd};
}

sub isMenuItem {
    !! $_[0]{menu};
}

1;
