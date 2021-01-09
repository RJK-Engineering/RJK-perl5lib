use strict;
use warnings;

use RJK::File::Sidecar;

my $path = 'c:\test\file.ext';
print "$path\n";

RJK::File::Sidecar->getSidecarFiles($path, sub {
    return if ! /\.jpg$/i;
    my ($sidecar, $dir, $name, $nameStart) = @_;
    print "$dir\\$sidecar\n";
});

