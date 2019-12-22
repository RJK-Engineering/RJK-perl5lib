=begin TML

---+ package TotalCmd::Command
A Total Commander command.

---++ Object creation

---+++ new(%attrs) -> TotalCmd::Command

---++ Object attributes

Return object attribute value if called without arguments, set object
attribute value and return the same value otherwise.

---+++ name($name) -> $name

Name (=cm_*=, =em_*=).

---+++ number($number) -> $number

Number (=totalcmd.inc=).

---+++ button([$button]) -> $button
Icon resource string.
Format:
First icon  = "filename",
second icon = "filename,1"
(icon numbers start at 0)

---+++ cmd([$cmd]) -> $cmd
Command string.

---+++ param([$param]) -> $param
Parameter string.

---+++ path([$path]) -> $path
Start path.

---+++ iconic([$iconic]) -> $iconic
Window size: 1 = minimize, -1 = maximize.

---+++ menu([$menu]) -> $menu
Description/tooltip/title.

---+++ key([$key]) -> $key
Shortcut key defined with a command.

---+++ shortcuts([\@shortcuts]) -> \@shortcuts
Shortcut keys defined in Options > Misc.

=cut
###############################################################################

package TotalCmd::Command;

use Class::AccessorMaker {
    source => undef,    # Inc/StartMenu/DirMenu/User/Button
    name => undef,      # name (cm_*, em*)
    number => undef,    # number (totalcmd.inc)
    button => undef,    # icon
                        # first icon  = "filename"
                        # second icon = "filename,1"
                        # (icon numbers start at 0)
    cmd => undef,       # command
    param => undef,     # parameters
    path => undef,      # start path
    iconic => undef,    # 1 = minimize, -1 = maximize
    menu => undef,      # description/tooltip/title
    key => undef,       # shortcut key (command config)
    shortcuts => [],    # shortcut keys (Options > Misc)
};

1;
