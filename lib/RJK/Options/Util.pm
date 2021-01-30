package RJK::Options::Util;

use strict;
use warnings;

use RJK::Cwd;
use RJK::Files;
use RJK::ListFiles;

sub traverseFiles {
    my ($self, $opts, $visitor) = @_;
    if ($opts->{listFile}) {
        RJK::ListFiles->traverse($opts->{listFile}, $visitor, $opts);
    } elsif ($opts->{path}) {
        RJK::Files->traverse($opts->{path}, $visitor, $opts);
    } elsif (@ARGV) {
        RJK::Files->traverse($_, $visitor) for @ARGV;
    } elsif ($opts->{stdin}) {
        RJK::Files->traverse($_, $visitor) while <>;
    } else {
        RJK::Files->traverse(RJK::Cwd->get, $visitor, $opts);
    }
}

1;
