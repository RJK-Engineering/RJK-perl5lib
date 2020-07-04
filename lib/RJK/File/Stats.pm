package RJK::File::Stats;

use strict;
use warnings;

use RJK::Files;
use RJK::File::TraverseStats;
use RJK::FileVisitor::StatsWrapper;

sub traverse {
    my ($path, $visitor, $opts, $stats) = @_;
    $visitor ||= bless {}, 'RJK::FileVisitor';

    $stats ||= createStats();
    $visitor = new RJK::FileVisitor::StatsWrapper($visitor, $stats);

    RJK::Files::traverse($path, $visitor, $opts);

    delete $stats->{dirStats};
    return $stats;
}

sub createStats {
    return new RJK::File::TraverseStats();
}

1;
