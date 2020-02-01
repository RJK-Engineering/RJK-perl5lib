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
    my $propertiesFormat = $path =~ /\.properties$/i;
    my $eat;

    open my $fh, '<', $path or die "$!";
    while (<$fh>) {
        s/^\s+//;                                           # trim leading space
        next unless /./;                                    # skip empty line
        next if /^[!#]/;                                    # skip comments
        s/\s+$//;                                           # trim trailing space

        if ($eat) {
            my $option = $eat;
            $eat = s/\\$//;                                 # remove backslash

            if (! $propertiesFormat) {
                s/\s+$//;                                   # trim trailing space after removing backslash
                $options->{$option} .= "\n";
            }
            $options->{$option} .= $_;

            $eat = $option if $eat;
            next;
        }
        $eat = s/\\$//;                                     # remove backslash

        my @option = split /=/, $_, 2;
        $option[1] =~ s/^\s+//;                             # trim leading space
        $option[0] =~ s/\s+$//;                             # trim trailing space
        $option[0] =~ s/\.(\w?)/\U$1/g;                     # make camelCase
        if ($propertiesFormat) {
            $option[1] =~ s/\\([rnt'"\\])/"qq|\\$1|"/gee;   # escaped characters
        } elsif ($eat) {
            $option[1] =~ s/\s+$//;                         # trim trailing space after removing backslash
        }

        $options->{$option[0]} = $option[1];

        $eat = $option[0] if $eat;
    }
}

1;
