use strict;
use warnings;

use Data::Dump;
use RJK::Filecheck::Dir;

my $path = 'c:\temp\1';
my $dir = RJK::Filecheck::Dir->new($path);

dd $dir->getProperties();

print $dir->hasProperty('a')||"no", "\n";
print $dir->hasProperty('b')||"no", "\n";
print $dir->hasProperty('wertyuio')||"no", "\n";

print $dir->getProperty('a')//"undef", "\n";
print $dir->getProperty('b')//"undef", "\n";
print $dir->getProperty('hgfds')//"undef", "\n";

$dir->setProperty('propname1', 'val1');
$dir->setProperty('propname2', 0);
$dir->setProperty('propname3', "break\nval2");

dd $dir->getProperties();

$dir->setFileProperty('file.ext', 'propname1', 'val1');
$dir->setFileProperty('file2.ext', 'propname2', 0);
$dir->setFileProperty('file.ext', 'propname3', "break\nval2");

my $props = $dir->getFileProperties('file.ext');
use Data::Dump;
dd $props;

$dir->saveProperties();
