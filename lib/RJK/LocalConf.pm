###############################################################################
=begin TML

---+ package RJK::LocalConf

=cut
###############################################################################

package RJK::LocalConf;

use strict;
use warnings;

use RJK::Util::Properties;

###############################################################################
=pod

---+++ GetOptions($filename, %defaultOptions) -> %options or \%options
Load options from config file(s) in local directories using environment variables.
Directory paths in order of precedence:
subdirectory "RJK-utils" of LOCALAPPDATA, LOCALAPPDATA, APPDATA.
   * =$filename= - path to config file relative to local data directory
   * =%defaultOptions= - default options to return if not present in local config
   * =%options= - option key/values

=cut
###############################################################################

sub GetOptions {
    my $filename = shift;
    my %options = @_;

    my @paths = (
        $ENV{APPDATA},      # roaming conf
        $ENV{LOCALAPPDATA}, # local conf
        "$ENV{LOCALAPPDATA}/RJK-utils"
    );

    foreach my $path (@paths) {
        loadConf("$path/$filename", \%options) if -e "$path/$filename";
    }

    return wantarray ? %options : \%options;
}

sub loadConf {
    my ($path, $options) = @_;

    my $props = new RJK::Util::Properties();
    $props->load($path);

    while (my ($k, $v) = each %{$props->hash}) {
        $k =~ s/\.(\w?)/\U$1/g; # make camelCase
        $options->{$k} = $v;
    }
}

1;
