###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::UserCmd
A Total Commander user command item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::UserCmd

---++ Object attributes

---+++ name([$name]) -> $name
Name (=em_*=).

=cut
###############################################################################

package RJK::TotalCmd::Item::UserCmd;
use parent 'RJK::TotalCmd::Item::Button';

use strict;
use warnings;

use Class::AccessorMaker {
    name => undef    # name (em_*)
};

1;
