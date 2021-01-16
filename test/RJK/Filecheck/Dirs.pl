use strict;
use warnings;

use Data::Dump;
use RJK::Filecheck::Dirs;

my $dirpath = 'c:\temp\test';
my $p = RJK::Filecheck::Dirs->getProperties($dirpath);
dd $p;
