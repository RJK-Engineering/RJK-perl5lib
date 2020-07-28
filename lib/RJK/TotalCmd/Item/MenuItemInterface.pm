=begin TML

---+ package RJK::TotalCmd::Item::MenuItemInterface

---+++ isSeparator() -> $boolean
Title = '-'.

---+++ isSubmenuBegin() -> $boolean
Title = '-' + submenu title.

---+++ isSubmenuEnd() -> $boolean
Title = '--'.

=cut
###############################################################################

package RJK::TotalCmd::Item::MenuItemInterface;

use strict;
use warnings;

sub isSeparator {
    $_[0]{menu} eq '-';
}

sub isSubmenuBegin {
    $_[0]{menu} =~  /^-[^-]/;
}

sub isSubmenuEnd {
    $_[0]{menu} eq '--';
}

1;
