use strict;
use warnings;

use Data::Dump;
use RJK::Util::ProcessMonitor;

my $m = new RJK::Util::ProcessMonitor();
$m->setImageName("mpc-hc64.exe");
$m->addObserver(sub { dd(\@_) });
while (1) {
    $m->poll();
    sleep 1;
}
