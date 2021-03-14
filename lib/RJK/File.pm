package RJK::File;

use strict;
use warnings;

use Exceptions;
use OpenFileException;

sub open {
    my ($self, $path) = @_;
    CORE::open my $fh, '<:encoding(utf8)', $path
        or throw OpenFileException(error => "$!: $path", file => $path, mode => 'read');
    return $fh;
}

sub openWritable {
    my ($self, $path) = @_;
    return *STDOUT if $path eq '-';

    CORE::open my $fh, '>:encoding(utf8)', $path
        or throw OpenFileException(error => "$!: $path", file => $path, mode => 'write');
    return $fh;
}

sub toString {
    $_[0]{path};
}

1;
