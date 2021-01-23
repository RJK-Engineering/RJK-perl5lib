###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::Button
A Total Commander button bar item.

---++ Object methods

---+++ new(%attrs) -> $button
Returns a new =RJK::TotalCmd::Item::Button= object.

---+++ button($button) -> $iconResource
Icon resource string.
Format:
First icon  = "filename",
second icon = "filename,1"
(icon numbers start at 0)

=cut
###############################################################################

package RJK::TotalCmd::Item::Button;
use parent 'RJK::TotalCmd::Item::Command';
use parent 'RJK::TotalCmd::Item::ButtonInterface';

use strict;
use warnings;

use Class::AccessorMaker {
    button => ""
};

1;
