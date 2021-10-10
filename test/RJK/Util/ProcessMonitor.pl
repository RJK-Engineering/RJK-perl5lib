use strict;
use warnings;

use Data::Dump;
use RJK::Util::ProcessMonitor;

my $executableFilename = shift;

my $m = new RJK::Util::ProcessMonitor();
$m->setImageName($executableFilename);
$m->addObserver(sub { dd(\@_) });
while (1) {
    $m->poll();
    sleep 1;
}
