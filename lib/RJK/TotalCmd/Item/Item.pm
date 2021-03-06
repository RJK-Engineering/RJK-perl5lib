###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::Item
Abstract class.
A Total Commander menu item, button bar item, user command item or internal command item.

---++ Object methods

---+++ number($number) -> $number
Number.

---+++ menu($menu) -> $menu
Description/tooltip/title.

=cut
###############################################################################

package RJK::TotalCmd::Item::Item;
use parent RJK::TotalCmd::Item::ItemInterface;

use strict;
use warnings;

use Class::AccessorMaker {
    number => undef,    # number
    menu => undef,      # description/tooltip/title
}, "no_new";

1;
