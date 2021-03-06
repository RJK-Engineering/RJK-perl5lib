package RJK::Util::JSON;

use strict;
use warnings;

use JSON;
use Try::Tiny;

use Exceptions;
use FileException;
use OpenFileException;

sub read {
    my ($self, $file) = @_;

    throw FileException(error => "Not a file: $file", file => $file) if ! -f $file;
    throw FileException(error => "File is empty: $file", file => $file) if -z $file;

    local $/; # slurp entire file
    open my $fh, '<', $file
        or throw OpenFileException(error => "$!: $file", file => $file);

    my $data;
    try {
        $data = JSON->new->decode(<$fh>);
    } catch {
        throw Exception(shift);
    } finally {
        close $fh;
    };

    return $data;
}

sub write {
    my ($self, $file, $data) = @_;

    open my $fh, '>', $file
        or throw OpenFileException(file => $file, error => "$!");

    try {
        #~ print $fh JSON->new->allow_nonref->convert_blessed->canonical->pretty->encode($data);
        print $fh JSON->new->canonical->pretty->encode($data);
    } catch {
        throw Exception(shift);
    } finally {
        close $fh;
    };
}

1;
