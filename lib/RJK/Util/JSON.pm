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
    throw FileException(error => "Not a file: $file", file => $file) if !-f $file;

    local $/; # slurp entire file
    open my $fh, '<', $file or throw OpenFileException(error => "$!: $file", file => $file);
    my $data = <$fh>;
    close $fh;

    return JSON->new->decode($data) if $data ne "";
}

sub write {
    my ($self, $file, $data) = @_;
    my $json = JSON->new->convert_blessed->canonical->pretty->encode($data);

    open my $fh, '>', $file or throw OpenFileException(file => $file, error => "$!");
    print $fh $json;
    close $fh;
}

sub UNIVERSAL::TO_JSON {
    eval "require Data::Structure::Util"
        or throw Exception("Data::Structure::Util package required to convert objects to JSON");
    my $self = shift;

    my $ref; # new reference required, TO_JSON is not allowed to return self
    eval { $ref = {%$self} }
        or throw Exception("Only blessed HASH objects allowed in conversion to JSON");
    Data::Structure::Util::unbless($ref);
    return $ref;
}

1;
