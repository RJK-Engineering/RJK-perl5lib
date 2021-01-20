use strict;
use warnings;

use RJK::Filecheck::NameParser;

my $np = new RJK::Filecheck::NameParser([{
    regex => ['(?<name>.+) - (?:youtube-)? (?<id>[\w-]{11}) (?: \.f\d+ )? (?: \. (?:mp4|webm) )? $'],
    properties => { site => "youtube" },
}]);

my $name = "Video-RD-9Ghvt480.mp4";
my $props = $np->parse($name);

use Data::Dump;
dd $props;

use RJK::Filecheck;

$np = RJK::Filecheck->createNameParser('c:\Users\Rob\AppData\Local\RJK-utils\filecheck\filenames');
$props = $np->parse($name);
dd $props;
