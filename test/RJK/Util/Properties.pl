use strict;
use warnings;

use RJK::Util::Properties;

my $p = RJK::Util::Properties->new;
$p->read(shift);
use Data::Dump;
dd $p;

$p->write("test~.properties");
