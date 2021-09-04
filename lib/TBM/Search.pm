package TBM::Search;

use strict;
use warnings;

sub fetch {
    my ($self, $class, $where, $callback) = @_;
    my @keys = keys %$where;
    foreach (@keys) {
        next if !ref $where->{$_};
        $where->{$_.'_id'} = $where->{$_}{id};
        delete $where->{$_};
    }
    ::table($class)->select($where, $callback);
}


1;
