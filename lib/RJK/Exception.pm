package RJK::Exception;

use strict;
use warnings;

sub printAndExit {
    if ( UNIVERSAL::isa($_, 'Exception') ) {
        print STDERR ref, "\nerror = ", $_->error, "\n";
        if ($_->Fields) {
            foreach my $field ($_->Fields) {
                print STDERR "$field = ", $_->$field//"(undef)", "\n";
            }
        }
    } else {
        print STDERR "$_\n";
    }
    exit 1;
}

sub verbosePrintAndExit {
    if ( UNIVERSAL::isa($_, 'Exception') ) {
        print STDERR ref, "\n\n";
        print STDERR "Error message:\n", $_->error, "\n";
        if ($_->Fields) {
            print STDERR "\nFields:\n";
            foreach my $field ($_->Fields) {
                print STDERR "$field = ", $_->$field//"(undef)", "\n";
            }
        }
        print STDERR "\n", $_->trace->as_string;
    } else {
        print STDERR "$_\n", Devel::StackTrace->new->as_string;
    }
    exit 1;
}

1;
