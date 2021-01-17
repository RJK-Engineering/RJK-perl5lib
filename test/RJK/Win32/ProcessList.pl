use strict;
use warnings;

use RJK::Win32::ProcessList;

my $pl = RJK::Win32::ProcessList->getProcessList();

use Data::Dump;
dd $pl->[0];
dd $pl->[1];

$pl = RJK::Win32::ProcessList->getProcessList("mpc-hc64.exe");
dd $pl;

$pl = RJK::Win32::ProcessList->getByPid(0);
dd $pl;
