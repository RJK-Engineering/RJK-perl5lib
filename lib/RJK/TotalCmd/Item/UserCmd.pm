###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::UserCmd
A Total Commander user command item.

---++ Object methods

---+++ new(%attrs) -> $userCmd
Returns a new =RJK::TotalCmd::Item::UserCmd= object.

---+++ name($name) -> $name
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
