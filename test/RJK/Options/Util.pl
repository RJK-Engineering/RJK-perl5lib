use strict;
use warnings;

use RJK::Options::Util;
my $opts = {
    path => 'c:/temp/1',
    #~ listFile => 'paths.txt',
    maxDepth => 1,
};
RJK::Options::Util->traverseFiles($opts, sub {print "$_\n"});
