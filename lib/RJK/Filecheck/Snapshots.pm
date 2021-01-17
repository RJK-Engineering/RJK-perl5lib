package RJK::Filecheck::Snapshots;

use strict;
use warnings;

use RJK::Filecheck::CreateSnapshotsVisitor;
use RJK::Files;
use RJK::ListFiles;

my $opts;

sub create {
    my $self = shift;
    $opts = shift;
    my $visitor = new RJK::Filecheck::CreateSnapshotsVisitor($opts);

    if ($opts->{listFile}) {
        RJK::ListFiles->traverse($opts->{listFile}, $visitor);
    } elsif ($opts->{path}) {
        RJK::Files->traverse($opts->{path}, $visitor);
    }
}

1;
