use strict;
use warnings;

use RJK::Drives;

my $label = RJK::Drives->getLabel("C:\\");
print "$label\n";

my $path = RJK::Drives->getPathOnVolume("C:\\dir\\file");
print "$path\n";
