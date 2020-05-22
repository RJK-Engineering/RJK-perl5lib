=begin TML

---+ package RJK::TotalCmd::Item::Command
A Total Commander command.

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::Item::Command

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

---++ Object methods

---+++ getCommandName() -> $name
Internal or user command from cmd (cm_*, em_*).

---+++ isCommand() -> $boolean
==cmd= is not empty.

=cut
###############################################################################

package RJK::TotalCmd::Item::Command;
use parent 'RJK::TotalCmd::Item::Item';

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

sub getCommandName {
    return ($_[0]{cmd} =~ /^([ce]m_.*)/)[0];
}

sub isCommand {
    !! $_[0]{cmd};
}

1;
