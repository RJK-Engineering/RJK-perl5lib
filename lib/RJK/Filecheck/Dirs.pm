package RJK::Filecheck::Dirs;

use strict;
use warnings;

use RJK::Util::Properties;
use Try::Tiny;

sub getProperties {
    my ($class, $path) = @_;
    my $config = new RJK::Util::Properties();
    try {
        $config->load("$path/.dir.properties");
    } catch {};
    return $config;
}

1;
