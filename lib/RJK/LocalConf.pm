###############################################################################
=begin TML

---+ package RJK::LocalConf

=cut
###############################################################################

package RJK::LocalConf;

use strict;
use warnings;

use RJK::Env;
use RJK::Util::Properties;

###############################################################################
=pod

---++ Class methods

---+++ GetOptions($filename, %defaultOptions) -> %options or \%options
Load options from config file(s) stored in local data directories.
   * =$filename= - path to config file relative to local data directory
   * =%defaultOptions= - default options to return if not present in local config
   * =%options= - option key/values

=cut
###############################################################################

sub GetOptions {
    my ($filename, %options) = @_;
    loadProperties($_, \%options) for RJK::Env->findLocalFiles($filename);
    return wantarray ? %options : \%options;
}

sub loadProperties {
    my ($path, $options) = @_;
    my $props = new RJK::Util::Properties();
    $props->load($path);

    while (my ($k, $v) = each %{$props->hash}) {
        $k =~ s/\.(\w?)/\U$1/g; # make camelCase
        $options->{$k} = $v;
    }
}

1;
