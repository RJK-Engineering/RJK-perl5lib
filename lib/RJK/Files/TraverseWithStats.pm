package RJK::Files;

use strict;
use warnings;
no warnings 'redefine';

use RJK::File::TraverseStats;
use RJK::FileVisitor::StatsWrapper;

sub traverseWithStats {
    my ($self, $path, $visitor, $opts, $stats) = @_;
    $visitor ||= bless {}, 'RJK::FileVisitor';
    $stats //= &createStats;

    $visitor = new RJK::FileVisitor::StatsWrapper($visitor, $stats);
    $stats->{result} = $self->_traverse($path, $visitor, $opts);

    delete $stats->{dirStats};
    return $stats;
}

sub createStats {
    return new RJK::File::TraverseStats();
}

1;
