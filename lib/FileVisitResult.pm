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

@FileVisitResult::CONTINUE::ISA = qw(FileVisitResult);
@FileVisitResult::TERMINATE::ISA = qw(FileVisitResult);
@FileVisitResult::SKIP_SUBTREE::ISA = qw(FileVisitResult);
@FileVisitResult::SKIP_SIBLINGS::ISA = qw(FileVisitResult);
@FileVisitResult::SKIP_DIRS::ISA = qw(FileVisitResult);
@FileVisitResult::SKIP_FILES::ISA = qw(FileVisitResult);

sub matches {
    shift;
    UNIVERSAL::isa(my $result = shift, 'FileVisitResult') || return 0;
    foreach (@_) {
        return 1 if $result == $_;
    }
    return 0;
}

1;
