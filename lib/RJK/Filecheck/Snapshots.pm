package RJK::Filecheck::Snapshots;

use strict;
use warnings;

use RJK::Options::Util;
use RJK::Filecheck::CreateSnapshotsVisitor;

sub create {
    my ($self, $opts) = @_;
    my $visitor = new RJK::Filecheck::CreateSnapshotsVisitor($opts);
    RJK::Options::Util->traverseFiles($opts, $visitor);
}

1;
