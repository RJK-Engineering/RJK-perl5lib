package FileVisitResult;

use strict;
use warnings;

use constant {
    CONTINUE => bless([], 'FileVisitResult::CONTINUE'),
    TERMINATE => bless([], 'FileVisitResult::TERMINATE'),
    SKIP_SUBTREE => bless([], 'FileVisitResult::SKIP_SUBTREE'),
    SKIP_SIBLINGS => bless([], 'FileVisitResult::SKIP_SIBLINGS'),
    SKIP_DIRS => bless([], 'FileVisitResult::SKIP_DIRS'),
    SKIP_FILES => bless([], 'FileVisitResult::SKIP_FILES'),
};

sub matches {
    shift;
    my $result = shift // return 0;
    foreach (@_) {
        return 1 if $result == $_;
    }
    return 0;
}

1;
