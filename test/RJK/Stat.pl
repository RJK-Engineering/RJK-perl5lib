use strict;
use warnings;

use RJK::Stat;

my $path = shift || 'c:\swapfile.sys';

print "------\n";
my $s = RJK::Stat->get($path);
my $s1 = getValues();
print STDERR join "\n", sort keys %INC;
print "\n";

print "------\n";
$RJK::Stat::USE_FCNTL = 1;  # uses many other mods
$s = RJK::Stat->get($path);
my $s2 = getValues();
print STDERR join "\n", sort keys %INC;
print "\n";

print "------\n";
print "exists\t\t", $s1->{exists}, "\t", $s2->{exists}, "\n";
print "isReadable\t", $s1->{isReadable}, "\t", $s2->{isReadable}, "\n";
print "isWritable\t", $s1->{isWritable}, "\t", $s2->{isWritable}, "\n";
print "isExecutable\t", $s1->{isExecutable}, "\t", $s2->{isExecutable}, "\n";
print "size\t\t", $s1->{size}, "\t", $s2->{size}, "\n";
print "accessed\t", $s1->{accessed}, "\t", $s2->{accessed}, "\n";
print "modified\t", $s1->{modified}, "\t", $s2->{modified}, "\n";
print "created\t\t", $s1->{created}, "\t", $s2->{created}, "\n";
print "isDir\t\t", $s1->{isDir}, "\t", $s2->{isDir}, "\n";
print "isFile\t\t", $s1->{isFile}, "\t", $s2->{isFile}, "\n";

sub getValues {{
    exists => $s->exists,
    isReadable => $s->isReadable,
    isWritable => $s->isWritable,
    isExecutable => $s->isExecutable,
    size => $s->size,
    accessed => $s->accessed,
    modified => $s->modified,
    created => $s->created,
    isDir => $s->isDir,
    isFile => $s->isFile,
}}
