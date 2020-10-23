package RJK::File::Paths;

use strict;
use warnings;

use File::Spec::Functions qw(canonpath catdir catpath splitpath);

sub get {
    my $path = catdir(grep {$_ ne ""} @_);

    my ($volume, $directories, $file) = splitpath($path);
    my ($basename, $extension) = ($file =~ /^(.+)\.(.+)$/);

    return bless {
        path => $path,
        dir => $file eq '' ? '' : catpath($volume, $directories, ''),
        name => $file,
        volume => $volume,
        directories => $directories,
        basename => $basename // $file,
        extension => $extension // ''
    }, 'RJK::File::Path';
}

1;
