###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::InternalCmd
A Total Commander internal command item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::InternalCmd

---++ Object attributes

---+++ name([$name]) -> $name
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
