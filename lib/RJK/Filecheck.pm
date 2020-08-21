package RJK::Filecheck;

use strict;
use warnings;

use Module::Load;

my $store;
my $storeModule = "RJK::Filecheck::Store";

sub getDrives {
    getStore()->getDrives();
}

sub getBackupDirs {
    getStore()->getBackupDirs();
}

sub storeBackupDirs {
    my ($class, $list) = @_;
    getStore()->storeBackupDirs($list);
}

sub getStore {
    if (! $store) {
        load $storeModule;
        $store = $storeModule;
    }
    return $store;
}

1;
