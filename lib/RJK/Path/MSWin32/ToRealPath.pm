package RJK::Path;

use strict;
use warnings;
no warnings 'redefine';

use RJK::Paths;
use Win32;

sub toRealPath {
    RJK::Paths->get(
        Win32::GetLongPathName(
            scalar Win32::GetFullPathName(
                $_[0]{path}
    )));
}

1;
