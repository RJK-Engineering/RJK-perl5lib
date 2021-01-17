use strict;
use warnings;

use RJK::Stat;

my $path = shift || 'c:\swapfile.sys';
my $s = RJK::Stat->get($path);

use Data::Dump;
dd $s;

print "exists\t\t", $s->exists, "\n";
print "isReadable\t", $s->isReadable, "\n";
print "isWritable\t", $s->isWritable, "\n";
print "isExecutable\t", $s->isExecutable, "\n";
print "size\t\t", $s->size, "\n";
print "accessed\t", $s->accessed, "\n";
print "modified\t", $s->modified, "\n";
print "created\t\t", $s->created, "\n";
print "isDir\t\t", $s->isDir, "\n";
print "isFile\t\t", $s->isFile, "\n";
print "isRegular\t", $s->isRegular, "\n";
print "isBlock\t\t", $s->isBlock, "\n";
print "isCharacter\t", $s->isCharacter, "\n";
