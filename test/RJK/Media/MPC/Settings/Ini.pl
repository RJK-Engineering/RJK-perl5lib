use RJK::Media::MPC::Settings::Ini;

my $path = 'c:\Program Files\Combined Community Codec Pack 64bit\MPC\mpc-hc64.ini';

my $ini = new RJK::Media::MPC::Settings::Ini($path)->read;

use Data::Dump;
dd $ini->getCommandMods;

1;