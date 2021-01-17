package RJK::File::Path;

use strict;
use warnings;
no warnings 'redefine';

my $splitFilenameRegex = qr{ ^ (.+)\.(.+) $ }x;

sub basename {
    ($_[0]{name} =~ /$splitFilenameRegex/)[0] // $_[0]{name} // '';
}

sub extension {
    ($_[0]{name} =~ /$splitFilenameRegex/)[1] // '';
}

1;
