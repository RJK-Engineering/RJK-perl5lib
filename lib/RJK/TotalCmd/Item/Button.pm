=begin TML

---+ package RJK::TotalCmd::Item::Button
A Total Commander button bar item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::Button

---++ Object attributes

---+++ button([$button]) -> $button
Icon resource string.
Format:
First icon  = "filename",
second icon = "filename,1"
(icon numbers start at 0)

---++ Object methods

---+++ isButton() -> $boolean
==cmd= and =button= are not empty.

---+++ isSeparator() -> $boolean
==cmd= or =button= is empty.

=cut
###############################################################################

package RJK::TotalCmd::Item::Button;
use parent 'RJK::TotalCmd::Item::Command';

use strict;
use warnings;

use Class::AccessorMaker {
    button => ""
};

sub isButton {
    $_[0]{cmd} && $_[0]{button};
}

sub isSeparator {
    ! $_[0]{cmd} || ! $_[0]{button};
}

1;
