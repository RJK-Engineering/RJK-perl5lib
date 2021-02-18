package RJK::Filecheck;

use strict;
use warnings;

use RJK::Drives;
use RJK::Module;

my $stores;

sub getPath {
    my ($self, $label, $dirpath) = @_;
    my $driveName = RJK::Drives->getDriveName($label);
    return "$driveName:$dirpath";
}

sub getStore {
    my ($self, $module) = @_;
    return $stores->{$module} if $stores->{$module};
    return $stores->{$module} = RJK::Module->load($module);
}

sub createNameParser {
    loadModule("CreateNameParser");
    &createNameParser;
}

sub loadModule {
    eval "require " . __PACKAGE__ . "::$_[0]";
}

1;
