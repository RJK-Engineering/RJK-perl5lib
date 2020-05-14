use strict;
use warnings;

use RJK::Win32::ProcessList ':ALL';

my $pl = GetProcessList();

use Data::Dump;
dd $pl->[0];
dd $pl->[1];

$pl = GetProcessList("mpc-hc64.exe");
dd $pl;

$pl = GetByPid(0);
dd $pl;
