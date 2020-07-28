=begin TML

---+ package RJK::TotalCmd::Item::Command
Abstract class.
A Total Commander command.

---++ Object attributes

---+++ cmd([$cmd]) -> $cmd
Command string.

---+++ param([$param]) -> $param
Parameter string.

---+++ path([$path]) -> $path
Start path.

---+++ iconic([$iconic]) -> $iconic
Window size: 1 = minimize, -1 = maximize.

---+++ key([$key]) -> $key
Shortcut key defined with a command.

---+++ shortcuts([\@shortcuts]) -> \@shortcuts
Shortcut keys defined in Options > Misc.

=cut
###############################################################################

package RJK::TotalCmd::Item::Command;
use parent 'RJK::TotalCmd::Item::Item';
use parent 'RJK::TotalCmd::Item::CommandInterface';

use strict;
use warnings;

use Class::AccessorMaker {
    cmd => undef,       # command
    param => undef,     # parameters
    path => undef,      # start path
    iconic => undef,    # 1 = minimize, -1 = maximize
    key => undef,       # shortcut key (command config)
    shortcuts => [],    # shortcut keys (Options > Misc)
};

1;
