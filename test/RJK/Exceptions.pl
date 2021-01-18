use strict;
use warnings;

use Try::Tiny;
use RJK::Exceptions;
use RJK::Exception;
use RJK::File::Exceptions;

try {
    #~ $! = 2; # "No such file or directory"
    #~ throw Exception("uitzonderlijk");
    #~ throw RJK::Exception("uitzonderlijk");
    throw RJK::FileException(error => "uitzonderlijk", file => "asjdfhksjdfhksdjfh");
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

    print "-------- Handle RJK::Exception\n";
    RJK::Exceptions->handle(
        'RJK::Exception' => sub { printf "%s: %s\n", ref, $_->error }
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
