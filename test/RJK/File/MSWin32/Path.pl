use strict;
use warnings;

use RJK::File::Path;
use RJK::File::Paths;

my $p = RJK::File::Paths::get('c:\microsoft vs code\code.visualelementsmanifest.xml');

use Data::Dump;
dd $p->toRealPath;

$p = RJK::File::Paths::get('c:\a\..\.\b');
dd $p->normalize;

dd $p->root;
