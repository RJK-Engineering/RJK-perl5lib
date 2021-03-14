###############################################################################
=begin TML

---+ package RJK::LocalConf

=cut
###############################################################################

package RJK::LocalConf;

use strict;
use warnings;

use RJK::Env;
use RJK::Util::JSON;
use RJK::Util::Properties;

###############################################################################
=pod

---++ Class methods

---+++ GetOptions($filename, %defaultOptions) -> %options or \%options
---+++ GetOptions(\@filenames, %defaultOptions) -> %options or \%options
   * =$filename= - path to config file relative to local data directory
   * =@filenames= - paths to config files relative to local data directory
   * =%defaultOptions= - default options to return if not present in local config
   * =%options= - option key/values

Load options from config file(s) stored in local data directories.

=cut
###############################################################################

sub GetOptions {
    my ($files, %options) = @_;
    $files = [$files] if not ref $files;
    foreach my $filename (@$files) {
        if ($filename =~ /\.properties$/) {
            loadProperties($_, \%options) for RJK::Env->findLocalFiles($filename);
        } elsif ($filename =~ /\.json$/) {
            loadJson($_, \%options) for RJK::Env->findLocalFiles($filename);
        } else {
            die "Unsupported file type: $filename";
        }
    }
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
    push @{$options->{configFiles}}, $path;
}

sub loadJson {
    my ($path, $options) = @_;
    my $json = RJK::Util::JSON->read($path);

    while (my ($k, $v) = each %$json) {
        $options->{$k} = $v;
    }
    push @{$options->{configFiles}}, $path;
}

1;
