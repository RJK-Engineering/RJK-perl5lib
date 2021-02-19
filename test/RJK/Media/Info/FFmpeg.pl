use strict;
use warnings;

use RJK::Media::Info::FFmpeg;
use Data::Dump;

my $path = shift;
my $i = RJK::Media::Info::FFmpeg->info($path);
dd $i;
