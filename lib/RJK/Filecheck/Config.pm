package RJK::Filecheck::Config;

use strict;
use warnings;

use RJK::Util::Properties;

my $config;

sub get {
    my ($class, $prop) = @_;
    $class->loadConfig() if ! $config;
    die "Missing configuration property: $prop" if ! $config->has($prop);
    return $config->get($prop) =~ s'%(.*?)%' $ENV{$1} // $1 && "%$1%" || "%" 'egr;
}

sub loadConfig {
    $config = new RJK::Util::Properties();
    if ($ENV{FILECHECK_CONF_FILE}) {
        $config->load($ENV{FILECHECK_CONF_FILE});
    } else {
        $config->load("$ENV{LOCALAPPDATA}/filecheck.properties");
    }
}

1;
