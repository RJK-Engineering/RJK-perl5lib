package File::Visitor;

use strict;
use warnings;

use File::Visitor::Wrapper;
use Scalar::Blessed::Util qw(is_of_type);

# $_ is set to file's path

sub new {
    my $self = bless {}, shift;
    $self->{dieOnVisitFileFailed} = 1;
    $self;
}

# Static function for getting Visitor object from arguments.
sub getVisitor {
    my %opts = @_ % 2 ? (visitor => @_) : @_;

    if (ref $opts{visitor}) {
        if (is_of_type File::Visitor, $opts{visitor}) {
            return $opts{visitor};
        } else {
            die "Not a File::Visitor";
        }
    }

    if ($opts{preVisitDir} || $opts{postVisitDir}  ||
        $opts{visitFile} || $opts{visitFileFailed} ||
        $opts{fileSkipped} || $opts{dirSkipped}
    ) {
        return new File::Visitor::Wrapper(
            preVisitDir => $opts{preVisitDir},
            postVisitDir => $opts{postVisitDir},
            visitFile => $opts{visitFile},
            visitFileFailed => $opts{visitFileFailed},
            fileSkipped => $opts{fileSkipped},
            dirSkipped => $opts{dirSkipped},
        );
    }
}

# Invoked for a directory before files in the directory are visited.
# Subdirectories are visited after visiting the files.
sub preVisitDir {
    my ($self, $dir) = @_;
}

# Invoked for a directory after files in the directory have been visited.
# Subdirectories are visited after visiting the files.
# $error is undef if there was no error
sub postVisitDir {
    my ($self, $dir, $error) = @_;
}

# Invoked for a file in a directory.
sub visitFile {
    my ($self, $file) = @_;
}

# Invoked for a file that could not be visited.
sub visitFileFailed {
    my ($self, $file, $error) = @_;
    die "$error for $_" if $self->{dieOnVisitFileFailed};
}

# Invoked for a filtered file.
sub fileSkipped {
    my ($self, $file) = @_;
}

# Invoked for a filtered directory.
sub dirSkipped {
    my ($self, $dir) = @_;
}

1;
