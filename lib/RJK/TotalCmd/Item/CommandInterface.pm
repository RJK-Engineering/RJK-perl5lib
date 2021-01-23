###############################################################################
=begin TML

---+ interface RJK::TotalCmd::Item::CommandInterface

---++ Methods

---+++ getCommandName() -> $name
Internal or user command from cmd (cm_*, em_*).

---+++ isInternal() -> $boolean
==cmd= contains an internal command name (cm_*)

---+++ isUser() -> $boolean
==cmd= contains a user command name (em_*)

=cut
###############################################################################

package RJK::TotalCmd::Item::CommandInterface;

use strict;
use warnings;

sub getCommandName {
    ($_[0]{cmd} =~ /^([ce]m_.*)/)[0];
}

sub isInternal {
    $_[0]{cmd} =~ /^cm_/;
}

sub isUser {
    $_[0]{cmd} =~ /^em_/;
}

1;
