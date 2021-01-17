use strict;
use warnings;

use RJK::Path;
use RJK::Paths;

my $p = RJK::Paths->get('c:\microsoft vs code\code.visualelementsmanifest.xml');

use Data::Dump;
dd $p->toRealPath;

$p = RJK::Paths->get('c:\a\..\.\b');
dd $p;
dd $p->normalize;

$p = RJK::Paths->get('c:');
dd $p;
dd scalar $p->names;

$p = RJK::Paths->get('adsd\.asdd.sd');
dd $p;
dd $p->parent;
dd $p->subpath(1,2);
dd $p->basename;
dd $p->extension;
