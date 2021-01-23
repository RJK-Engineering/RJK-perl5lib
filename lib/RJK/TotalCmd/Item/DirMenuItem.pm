###############################################################################
=begin TML

---+ package RJK::TotalCmd::Item::DirMenuItem
A Total Commander directory menu item.

---++ Object methods

---+++ new(%attrs) -> $dirMenuItem
Returns a new =RJK::TotalCmd::Item::DirMenuItem= object.

---+++ cmd($cmd) -> $cmd
---+++ path($path) -> $path

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
