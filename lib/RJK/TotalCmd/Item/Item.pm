=begin TML

---+ package RJK::TotalCmd::Item::Item
A Total Commander menu item, button bar item, user command item or internal command item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::Item

---++ Object attributes

---+++ number([$number]) -> $number
Number.

---+++ menu([$menu]) -> $menu
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
};

1;
