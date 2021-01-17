package RJK::File::Path;

use strict;
use warnings;
no warnings 'redefine';

use RJK::File::Paths;
use Win32;

sub toRealPath {
    RJK::File::Paths::get(
        Win32::GetLongPathName(
            scalar Win32::GetFullPathName(
                $_[0]{path}
    )));
}

1;
