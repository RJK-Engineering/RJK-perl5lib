package RJK::File::Stats;

use strict;
use warnings;

use RJK::Files;
use RJK::File::TraverseStats;
use RJK::FileVisitor::StatsWrapper;

sub Traverse {
    my ($path, $visitor, $opts, $stats) = @_;
    $visitor ||= bless {}, 'RJK::FileVisitor';

    $stats ||= CreateStats();
    $visitor = new RJK::FileVisitor::StatsWrapper($visitor, $stats);

    RJK::Files::Traverse($path, $visitor, $opts);

    delete $stats->{dirStats};
    return $stats;
}

sub CreateStats {
    return new RJK::File::TraverseStats();
}

1;
