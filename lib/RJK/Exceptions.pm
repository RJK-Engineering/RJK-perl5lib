package RJK::Exceptions;

use strict;
use warnings;

use Devel::StackTrace;
require Exception::Class;

my $exceptionBaseClass = $Exception::Class::BASE_EXC_CLASS;
my $verbose = 0;

$SIG{__DIE__} = sub {
    if (UNIVERSAL::can($_[0], "rethrow")) {
        $_[0]->rethrow;
    } else {
        $exceptionBaseClass->throw(shift);
    }
};

sub _handle {
    return 0 if handleUnknownErrors();
    my $self = shift;
    my $default = shift if @_ % 2;
    my @exceptions = (@_, $exceptionBaseClass => $default || \&printException);

    while (my ($name, $handler) = splice @exceptions, 0, 2) {
        next if ! $_->isa($name);
        $handler->();
        return 1;
    }

    &printException;
    return 0;
}

sub handle {
    $verbose = 0;
    &_handle;
}

sub handleOneline {
    $verbose = -1;
    &_handle;
}

sub handleVerbose {
    $verbose = 1;
    &_handle;
}

sub handleUnknownErrors {
    if (ref) {
        return 0 if $_->isa($exceptionBaseClass);
        print STDERR "Unknown error type: ", ref,
            $! && ". Internal error: $!",
            ".", $verbose > -1 && "\n";
    } else {
        s/[\v\.]+$//;
        print STDERR "Unexpected error", $_ && ": $_",
            $! && ". Internal error: $!",
            ".", $verbose > -1 && "\n";
    }
    &printStackTrace if $verbose;
    return 1;
}

sub printStackTrace {
    if ( UNIVERSAL::isa($_, $exceptionBaseClass) ) {
        print STDERR $_->trace->as_string;
    } else {
        print STDERR Devel::StackTrace->new->as_string;
    }
}

sub printException {
    if ($verbose == -1) {
        &printExceptionOneline;
    } elsif ($verbose == 0) {
        &printExceptionOneline;
        print STDERR "\n";
        &printExceptionFields;
    } else {
        &printExceptionOneline;
        print STDERR "\n";
        &printExceptionFields;
        print STDERR "\n";
        &printStackTrace;
    }
}

sub printExceptionOneline {
    print STDERR ref, " ", $_->error, " at ", $_->trace->frame(1)->subroutine,
        " line ", $_->trace->frame(0)->line;
}

sub printExceptionFields {
    return if ! $_->Fields;
    foreach my $field ($_->Fields) {
        print STDERR "$field = ", $_->$field//"(undef)", "\n";
    }
}

1;
