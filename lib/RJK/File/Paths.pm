package RJK::File::Paths;

use strict;
use warnings;

my $separatorsRegex = qr{ [\\\/]+ }x;
my $splitPathRegex = qr{ ^ (\w): (?: (\\.+)\\(.+) | \\(.+) )? $ }x;

sub get {
    my $path = ucfirst join "\\", @_;
    $path =~ s/$separatorsRegex/\\/g;
    $path =~ s/$separatorsRegex$//;

    my ($drive, $directories, $file, $fileInRoot) = $path =~ /$splitPathRegex/;
    if (not defined $file) {
        if (defined $fileInRoot) {
            $file = $fileInRoot;
        } else {
            $file = '';
            $path .= '\\';
        }
        $directories = '\\';
    }

    return bless {
        path => $path,
        name => $file,
        drive => $drive,
        directories => $directories,
    }, 'RJK::File::Path';
}

1;
