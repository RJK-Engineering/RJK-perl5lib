package RJK::File::Paths;

use strict;
use warnings;

my $separatorsRegex = qr{ [\\\/]+ }x;
my $splitPathRegex = qr{ ^ ((\w):) (?: (\\.+)\\(.+) | \\(.*) )? $ }x;
my $splitFilenameRegex = qr{ ^ (.+)\.(.+) $ }x;

sub get {
    my $path = ucfirst join "\\", @_;
    $path =~ s/$separatorsRegex/\\/g;
    $path =~ s/$separatorsRegex$//;

    my ($volume, $drive, $directories, $file, $noparent) = $path =~ /$splitPathRegex/;
    if (not defined $file) {
        $file = $noparent // '';
        $directories = '';
    }
    my ($basename, $extension) = ($file =~ /$splitFilenameRegex/);

    return bless {
        path => $path,
        parent => $file eq '' ? '' : $volume.$directories,
        name => $file,
        volume => $volume,
        drive => $drive,
        directories => $directories,
        basename => $basename // $file,
        extension => $extension // ''
    }, 'RJK::File::Path';
}

1;
