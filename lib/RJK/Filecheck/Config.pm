package RJK::Filecheck::Config;

use strict;
use warnings;

use RJK::Env;
use RJK::Util::Properties;

my $config;

sub get {
    my ($class, $prop) = @_;
    $class->loadConfig() if ! $config;
    die "Missing configuration property: $prop" if ! $config->has($prop);
    return RJK::Env->subst($config->get($prop));
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
