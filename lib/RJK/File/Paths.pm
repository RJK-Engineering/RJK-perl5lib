package RJK::File::Paths;

use strict;
use warnings;

my $separator = RJK::File::Path::separator();
my $sep = quotemeta $separator;
my $separatorsRegex = qr{ [$sep]+ }x;
my $splitPathRegex = qr{ ^ (\w): (?: ($sep.+)$sep(.+) | $sep(.+) )? $ }x;

sub get {
    my $path = ucfirst join $separator, @_;
    $path =~ s/$separatorsRegex/$separator/g;
    $path =~ s/$separatorsRegex$//;

    my ($volume, $directories, $file, $fileInRoot) = $path =~ /$splitPathRegex/;
    if (not defined $file) {
        if (defined $fileInRoot) {
            $file = $fileInRoot;
        } else {
            $file = '';
            $path .= $separator;
        }
        $directories = $separator;
    }

    return bless {
        path => $path,
        name => $file,
        volume => $volume,
        directories => $directories,
    }, 'RJK::File::Path';
}

1;
