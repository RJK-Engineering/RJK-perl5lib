package RJK::Cwd;

use strict;
use warnings;

use RJK::Paths;
require Cwd;

sub get {
    RJK::Paths->get(&Cwd::getcwd)->{path};
}

1;
