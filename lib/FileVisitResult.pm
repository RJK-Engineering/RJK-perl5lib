package FileVisitResult;

use strict;
use warnings;

use constant {
    CONTINUE => bless([], 'FileVisitResult::CONTINUE'),
    TERMINATE => bless([], 'FileVisitResult::TERMINATE'),
    SKIP_SUBTREE => bless([], 'FileVisitResult::SKIP_SUBTREE'),
    SKIP_SIBLINGS => bless([], 'FileVisitResult::SKIP_SIBLINGS'),
    SKIP_DIRS => bless([], 'FileVisitResult::SKIP_DIRS'),
    SKIP_FILES => bless([], 'FileVisitResult::SKIP_FILES')
};

@FileVisitResult::CONTINUE::ISA =
@FileVisitResult::TERMINATE::ISA =
@FileVisitResult::SKIP_SUBTREE::ISA =
@FileVisitResult::SKIP_SIBLINGS::ISA =
@FileVisitResult::SKIP_DIRS::ISA =
@FileVisitResult::SKIP_FILES::ISA = __PACKAGE__;

sub isaFileVisitResult {
    UNIVERSAL::isa($_[1], __PACKAGE__);
}

1;
