use strict;
use warnings;

use RJK::Win32::VolumeInfo;
my $volumes = RJK::Win32::VolumeInfo->getVolumes();

use Data::Dump;
dd $volumes;

my @volumes = RJK::Win32::VolumeInfo->getVolumes();
dd \@volumes;

my ($free, $total, $available) = RJK::Win32::VolumeInfo->getUsage('C:');
print "$free, $total, $available\n";
