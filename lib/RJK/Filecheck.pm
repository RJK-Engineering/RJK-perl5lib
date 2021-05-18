package RJK::Filecheck;

use strict;
use warnings;

use RJK::Module;
use RJK::Paths;
use RJK::Win32::VolumeInfo;

my $stores;

sub getRealPath {
    my ($self, $vpath) = @_;
    my @volumes = RJK::Win32::VolumeInfo->getVolumesByLabel($vpath->label);
    return RJK::Paths->get($volumes[0]{letter} . $vpath->relative) if @volumes == 1;
    die "Multiple volumes with same label mounted" if @volumes;
    return undef;
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
    eval "require " . __PACKAGE__ . "::$_[0]" or die "$@";
}

1;
