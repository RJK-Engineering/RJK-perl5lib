###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::InternalCmd
A Total Commander internal command item.

---++ Constructor

---+++ new(%attrs) -> $internalCmd
Returns a new =RJK::TotalCmd::Item::InternalCmd= object.

---++ Object methods

---+++ name($name) -> $name
Name (=cm_*=).

=cut
###############################################################################

package RJK::TotalCmd::Item::InternalCmd;
use parent 'RJK::TotalCmd::Item::Item';
use parent 'RJK::TotalCmd::Item::CommandInterface';

use strict;
use warnings;

use Class::AccessorMaker {
    name => undef,    # name (cm_*)
};

1;
