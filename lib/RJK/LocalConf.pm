###############################################################################
=begin TML

---+ package RJK::LocalConf

=cut
###############################################################################

package RJK::LocalConf;

use strict;
use warnings;

use RJK::AppData;

###############################################################################
=pod

---++ Class methods

---+++ GetOptions($filename, %defaultOptions) -> %options or \%options
---+++ GetOptions(\@filenames, %defaultOptions) -> %options or \%options
   * =$filename= - path to config file relative to data directory
   * =@filenames= - paths to config files relative to data directory
   * =%defaultOptions= - default options to return if not present in config
   * =%options= - option key/values

Load options from config file(s) stored in data directories.

=cut
###############################################################################

sub GetOptions {
    my $files = shift;
    my ($loaded, $data) = RJK::AppData->get($files, ref $_[0] ? $_[0] : {@_});
    $data->{configFiles} = $loaded;
    return wantarray ? %$data : $data;
}

1;
