package RJK::Filecheck;

use strict;
use warnings;

use Module::Load;

my $store;

sub getStore {
    my ($self, $module) = @_;
    return $store->{$module} if $store->{$module};
    load $module;
    return $store->{$module} = $module;
}

1;
