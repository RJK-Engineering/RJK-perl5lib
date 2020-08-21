package RJK::Util::JSON;

use strict;
use warnings;

use JSON;
use Try::Tiny;

use RJK::File::Exceptions;

sub read {
    my ($class, $file) = @_;

    throw RJK::FileException(error => "Not a file", file => $file) if ! -f $file;
    throw RJK::FileException(error => "File is empty", file => $file) if -z $file;

    local $/; # slurp entire file
    open my $fh, '<', $file
        or throw RJK::OpenFileException(file => $file, error => "$!");

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
    my ($class, $file, $data) = @_;

    open my $fh, '>', $file
        or throw RJK::OpenFileException(file => $file, error => "$!");

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
