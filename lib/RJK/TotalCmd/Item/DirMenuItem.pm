###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::DirMenuItem
A Total Commander directory menu item.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::DirMenuItem

=cut
###############################################################################

package RJK::TotalCmd::Item::DirMenuItem;
use parent 'RJK::TotalCmd::Item::MenuItem';

use strict;
use warnings;

use Class::AccessorMaker {
    cmd => undef,       # command
    path => undef,      # target path
};

1;
