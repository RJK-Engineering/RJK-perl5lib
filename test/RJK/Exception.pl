use strict;
use warnings;

use Try::Tiny;

use Exceptions;
use FileException;
use OpenFileException;

use RJK::Exceptions;

try {
    throw Exception("Uitzonderlijk");
    #~ throw OpenFileException(error => "Uitzonderlijk", file => "C:\\path");
} catch {
    RJK::Exceptions->handle();

    print "--------\n";
    RJK::Exceptions->handle(
        sub { printf "Unhandled %s: %s\n", ref, $_->error },
        #~ FileException => sub { printf "Handles subtype OpenFileException, OpenFileException handler will never be reached. %s: %s\n", ref, $_->error },
        OpenFileException => sub { printf "Handled OpenFileException %s: %s\n", ref, $_->error },
        FileException => sub { printf "Handled FileException %s: %s\n", ref, $_->error },
    );
    print "--------\n";
};
