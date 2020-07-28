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
