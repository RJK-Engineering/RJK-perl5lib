package RJK::File::Paths;

use strict;
use warnings;

use File::Spec::Functions qw(catdir catpath splitpath);

sub get {
    my $path = catdir(grep {$_ ne ""} @_);

    my ($volume, $directories, $file) = splitpath($path);
    $directories =~ s/\\$//;
    my ($basename, $extension) = ($file =~ /^(.+)\.(.+)$/);

    return bless {
        path => $path,
        parent => $file eq '' ? '' : catpath($volume, $directories, ''),
        name => $file,
        volume => $volume,
        drive => substr($volume, 0, 1),
        directories => $directories,
        basename => $basename // $file,
        extension => $extension // ''
    }, 'RJK::File::Path';
}

1;
