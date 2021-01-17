use strict;
use warnings;

use RJK::File::Path;
use RJK::File::Paths;

my $p = RJK::File::Paths::get('c:\microsoft vs code\code.visualelementsmanifest.xml');

use Data::Dump;
dd $p->toRealPath;

$p = RJK::File::Paths::get('c:\a\..\.\b');
dd $p;
dd $p->normalize;

$p = RJK::File::Paths::get('c:');
dd $p;
dd scalar $p->names;

$p = RJK::File::Paths::get('adsd\.asdd.sd');
dd $p;
dd $p->parent;
dd $p->subpath(1,2);
dd $p->basename;
dd $p->extension;
