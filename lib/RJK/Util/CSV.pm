package RJK::Util::CSV;

use strict;
use warnings;

use Exceptions;
use FileException;
use OpenFileException;

our $delimiter = ",";

sub read {
    my ($self, $file, $callback) = @_;
    $callback //= sub {};
    my @rows;
    throw FileException(error => "Not a file", file => $file) if ! -f $file;

    open my $fh, '<', $file or throw OpenFileException(error => "$!: $file", file => $file);
    while (<$fh>) {
        chomp;
        my $row = [split /\Q$delimiter\E/];
        push @rows, $row;
        last if $callback->($row);
    }
    close $fh;

    return \@rows;
}

sub write {
    my ($self, $file, $rows) = @_;
    open my $fh, '>', $file or throw OpenFileException(error => "$!: $file", file => $file);
    print $fh join($delimiter, @$_), "\n" for @$rows;
    close $fh;
}

1;
