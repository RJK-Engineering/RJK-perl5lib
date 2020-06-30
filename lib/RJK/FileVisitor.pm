package RJK::FileVisitor;

use strict;
use warnings;

# Invoked for a directory before entries in the directory are visited.
sub preVisitDir {
    my ($self, $dir, $stat, $files, $dirs) = @_;
}

# Invoked for a directory after files in the directory have been visited.
# Subdirectories are visited after visiting the files.
# TODO This method is also invoked when iteration of the directory completes prematurely (by a visitFile method returning SKIP_SIBLINGS, or an I/O error when iterating over the directory).
# $error is undef if there was no error
sub postVisitDir {
    my ($self, $dir, $error, $files, $dirs) = @_;
}

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
