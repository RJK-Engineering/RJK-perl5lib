package RJK::LocalConf;

use strict;
use warnings;

###############################################################################
=pod

---+++ GetOptions($filename, %defaultOptions) -> %options or \%options
Load options from file(s) stored in local data directory =$ENV{APPDATA}= and/or
=$ENV{LOCALAPPDATA}= where =$ENV{LOCALAPPDATA}= overrules =$ENV{APPDATA}=.
   * =$filename= - path to config file relative to local data directory
   * =%defaultOptions= - default options to return if not present in local config
   * =%options= - option key/values

=cut
###############################################################################

sub GetOptions {
    my $filename = shift;
    my %options = @_;

    # roaming conf
    my $path = "$ENV{APPDATA}/$filename";
    loadConf($path, \%options) if -e $path;

    # local conf, overrules roaming conf
    $path = "$ENV{LOCALAPPDATA}/$filename";
    loadConf($path, \%options) if -e $path;

    return wantarray ? %options : \%options;
}

sub loadConf {
    my ($path, $options) = @_;

    open my $fh, '<', $path or die "$!";
    while (<$fh>) {
        next if /^\W/;
        chomp;
        my @option = split /=/, $_, 2;
        $options->{$option[0]} = $option[1];
    }
}

1;

