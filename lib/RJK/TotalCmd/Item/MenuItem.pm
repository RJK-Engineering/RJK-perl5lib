=begin TML

---+ package RJK::TotalCmd::Item::MenuItem
A Total Commander menu item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::MenuItem

---++ Object methods

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
use parent 'RJK::TotalCmd::Item::MenuItemInterface';

1;
