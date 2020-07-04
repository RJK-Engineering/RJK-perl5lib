package RJK::File::Paths;

use strict;
use warnings;

use File::Spec::Functions qw(canonpath catdir catpath splitpath);

sub get {
    my $path = catdir(@_);
    $path = canonpath($path);

    my ($volume, $directories, $file) = splitpath($path);
    my ($basename, $extension) = ($file =~ /^(.+)\.(.+)$/);

    return {
        path => $path,
        dir => $file eq '' ? '' : catpath($volume, $directories, ''),
        name => $file,
        volume => $volume,
        directories => $directories,
        basename => $basename // $file,
        extension => $extension // ''
    };
}

1;
