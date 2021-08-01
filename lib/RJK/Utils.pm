###############################################################################
=begin TML

---+ package RJK::Utils

=cut
###############################################################################

package RJK::Utils;

use strict;
use warnings;

use RJK::AppData;

sub getAppData {
    RJK::AppData->get("RJK-utils/$_[1]");
}

sub storeAppData {
    RJK::AppData->write("RJK-utils/$_[1]", $_[2]);
}

1;
