use strict;
use warnings;

use Exceptions;
use FileException;

use RJK::Exceptions;
use Try::Tiny;

try {
    #~ $! = 2; # "No such file or directory"
    #~ throw Exception("uitzonderlijk");
    throw FileException(error => "uitzonderlijk", file => "asjdfhksjdfhksdjfh");
    #~ die "foutje";
} catch {
    print "\n\n\n\n\n\n\n\n\n\n\n";
    print "-------- Default\n";
    RJK::Exceptions->handle();

    print "-------- Oneliner\n";
    RJK::Exceptions->handleOneline();
    print "\n";

    print "-------- Verbose\n";
    RJK::Exceptions->handleVerbose();

    print "-------- Handle Exception\n";
    RJK::Exceptions->handle(
        'Exception' => sub { printf "%s: %s\n", ref, $_->error }
    );

    print "-------- Default handler\n";
    # handles all exceptions of base type Exception
    RJK::Exceptions->handle(sub {
        printf "%s: %s\n", ref, $_->error;
    });

    print "-------- Print stack trace\n";
    RJK::Exceptions->printStackTrace();
    print "--------";
};
