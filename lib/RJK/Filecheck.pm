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

sub createNameParser {
    loadModule("CreateNameParser");
    &createNameParser;
}

sub loadModule {
    eval "require " . __PACKAGE__ . "::$_[0]";
}

1;
