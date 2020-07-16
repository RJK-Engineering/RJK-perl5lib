package RJK::FileVisitor;

use strict;
use warnings;

# Invoked for a directory before entries in the directory are visited.
sub preVisitDir {
    my ($self, $dir, $stat, $files, $dirs) = @_;
}

# Invoked for a directory after entries in the directory, and all of
# their descendants, have been visited.
# $error is undef if there was no error.
# This method is also invoked when iteration of the directory completes
# prematurely (by a visitFile method returning SKIP_SIBLINGS, or an I/O
# error when iterating over the directory).
sub postVisitDir {
    my ($self, $dir, $error, $files, $dirs) = @_;
}

# Invoked for a directory after all files in the directory have been visited.
sub postVisitFiles {
    my ($self, $dir, $stat, $files, $dirs) = @_;
}

# Invoked for a file in a directory.
sub visitFile {
    my ($self, $file, $stat) = @_;
}

# Invoked for a file that could not be visited.
sub visitFileFailed {
    my ($self, $file, $error) = @_;
}

1;
