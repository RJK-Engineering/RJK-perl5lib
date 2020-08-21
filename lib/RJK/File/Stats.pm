package RJK::File::Stats;

use strict;
use warnings;

use RJK::Files;
use RJK::File::TraverseStats;
use RJK::FileVisitor::StatsWrapper;

sub traverse {
    my ($class, $path, $visitor, $opts, $totals) = @_;
    $visitor ||= bless {}, 'RJK::FileVisitor';

    my $stats = $class->createStats();
    $visitor = new RJK::FileVisitor::StatsWrapper($visitor, $stats);
    RJK::Files->traverse($path, $visitor, $opts);

    delete $stats->{dirStats};
    $totals->update($stats) if $totals;
    return $stats;
}

sub createStats {
    return new RJK::File::TraverseStats();
}

1;
