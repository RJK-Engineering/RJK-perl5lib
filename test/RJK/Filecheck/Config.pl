use strict;
use warnings;

use Data::Dump;
use RJK::Filecheck::Config;

my $v = RJK::Filecheck::Config->get('sites.conf.file');

dd $v;
