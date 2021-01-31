package RJK::Options::Util;

use strict;
use warnings;

use RJK::Cwd;
use RJK::Files;
use RJK::ListFiles;

sub traverseFiles {
    my ($self, $opts, $visitor, $stats) = @_;
    if ($opts->{listFile}) {
        RJK::ListFiles->traverse($opts->{listFile}, $visitor, $opts, $stats);
    } elsif ($opts->{path}) {
        RJK::Files->traverse($opts->{path}, $visitor, $opts, $stats);
    } elsif (@ARGV) {
        RJK::Files->traverse($_, $visitor, $opts, $stats) for @ARGV;
    } elsif ($opts->{stdin}) {
        RJK::Files->traverse($_, $visitor, $opts, $stats) while <>;
    } else {
        RJK::Files->traverse(RJK::Cwd->get, $visitor, $opts, $stats);
    }
}

1;
