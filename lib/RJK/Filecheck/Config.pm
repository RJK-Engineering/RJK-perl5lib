package RJK::Filecheck::Config;

use strict;
use warnings;

use RJK::Env;
use RJK::Util::Properties;

my $config;

sub get {
    my ($class, $prop, $default) = @_;
    $class->loadConfig() if ! $config;
    return RJK::Env->subst($config->get($prop, $default));
}

sub loadConfig {
    $config = new RJK::Util::Properties();
    if ($ENV{FILECHECK_CONF_FILE}) {
        $config->load($ENV{FILECHECK_CONF_FILE});
    } else {
        $config->load($_) for RJK::Env->findLocalFiles("RJK-utils/filecheck.properties");
    }
}

1;
