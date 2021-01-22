package FileVisitResult;

use strict;
use warnings;

use constant {
    CONTINUE => bless([], 'FileVisitResult'),
    TERMINATE => bless([], 'FileVisitResult'),
    SKIP_SUBTREE => bless([], 'FileVisitResult'),
    SKIP_SIBLINGS => bless([], 'FileVisitResult'),
    SKIP_DIRS => bless([], 'FileVisitResult'),
    SKIP_FILES => bless([], 'FileVisitResult'),
};

sub matches {
    shift;
    UNIVERSAL::isa(my $result = shift, 'FileVisitResult') || return 0;
    foreach (@_) {
        return 1 if $_ == $result;
    }
    return 0;
}

1;
