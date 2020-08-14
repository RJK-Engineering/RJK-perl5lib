use strict;
use warnings;

use RJK::Win32::VolumeInfo;
my $volumes = RJK::Win32::VolumeInfo->getVolumes();

use Data::Dump;
dd $volumes;

my ($free, $total, $available) = RJK::Win32::VolumeInfo->getDiskFree('C:');
print "$free, $total, $available\n";
