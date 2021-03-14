use strict;
use warnings;

use RJK::Options::Util;
my $opts = {
    #~ listFile => 'paths.txt',
    path => 'c:/temp/1',
    stdin => 1,
    maxDepth => 1,
};

if ($opts->{listFile}) {
    print "\$opts->{listFile}: $opts->{listFile}\n";
} elsif ($opts->{path}) {
    print "\$opts->{path}: $opts->{path}\n";
} elsif (@ARGV) {
    print "\@ARGV: @ARGV\n";
} elsif ($opts->{stdin}) {
    print "Standard input\n";
} else {
    print "Current working directory\n";
}
RJK::Options::Util->traverseFiles($opts, sub {print "$_\n"});
