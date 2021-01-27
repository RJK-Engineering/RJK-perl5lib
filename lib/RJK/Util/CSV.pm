package RJK::Util::CSV;

use strict;
use warnings;

use Exceptions;
use FileException;
use OpenFileException;

our $delimeter = ",";

sub read {
    my ($self, $file, $callback) = @_;
    $callback //= sub {};
    my @rows;
    throw FileException(error => "Not a file", file => $file) if ! -f $file;

    open my $fh, '<', $file or throw OpenFileException(file => $file, error => "$!");
    while (<$fh>) {
        chomp;
        my $row = [split /$delimeter/];
        push @rows, $row;
        last if $callback->($row);
    }
    close $fh;

    return \@rows;
}

sub write {
    my ($self, $file, $rows) = @_;
    open my $fh, '>', $file or throw OpenFileException(file => $file, error => "$!");
    print $fh join($delimeter, @$_), "\n" for @$rows;
    close $fh;
}

1;
