package RJK::FileSystems;

use strict;
use warnings;

use RJK::FileSystem;

sub getDefault {
    return new RJK::FileSystem();
}

1;
