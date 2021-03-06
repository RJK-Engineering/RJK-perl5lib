package RJK::Paths;

use strict;
use warnings;

use RJK::FileSystems;

my $separator = RJK::FileSystems->getDefault->separator;
my $sep = quotemeta $separator;
my $separatorsRegex = qr{ [$sep]+ }x;
my $splitPathRegex = qr{ ^ (?: (\w): )? (?: (.*)$sep(.+) )? $ }x;

sub get {
    my $self = shift;
    my $path = join($separator, grep {$_ ne ''} @_)
        =~ s|/|$separator|gr
        =~ s|$separatorsRegex|$separator|gr;
    my $i = index $path, '"';
    die "Illegal char <\"> at index $i: $path" if $i >= 0;
    my $trailingSeparator = $path =~ s|[$sep\s]+$||;

    my ($volume, $directories, $file) = $path =~ /$splitPathRegex/;
    if (not defined $file) {
        if ($volume) {
            if ($trailingSeparator) {
                $path .= $separator;
                $directories = $separator;
            }
        } else {
            $file = $path;
        }
    }
    if ($volume) {
        $path = ucfirst $path;
        $volume = ucfirst $volume;
    }

    return bless {
        path => $path,
        name => $file // '',
        volume => $volume // '',
        directories => $directories // '',
    }, 'RJK::Path';
}

1;
