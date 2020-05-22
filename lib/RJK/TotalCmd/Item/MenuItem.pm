=begin TML

---+ package RJK::TotalCmd::Item::MenuItem
A Total Commander menu item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::MenuItem

---++ Object methods

---+++ isCommand() -> $boolean
Title does not start with '-'.

---+++ isSeparator() -> $boolean
Title = '-'.

---+++ isSubmenuBegin() -> $boolean
Title = '-' + submenu title.

---+++ isSubmenuEnd() -> $boolean
Title = '--'.


=cut
###############################################################################

package RJK::TotalCmd::Item::MenuItem;
use parent 'RJK::TotalCmd::Item::Item';

use strict;
use warnings;

sub isCommand {
    $_[0]{menu} !~ /^-/;
}

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
