=begin TML

---+ package RJK::File::PathFinder
Find paths to files.

=cut

package RJK::File::PathFinder;

use strict;
use warnings;

use Exporter ();
use File::Spec::Functions qw(rel2abs);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    FindPath
);

###############################################################################
=pod

---++ FindPath(@paths) -> $path
Find first existing path.
With environment variable substitution.
Relative paths are translated to absolute paths.

=cut
###############################################################################

sub FindPath {
    my @paths = @_;
    my $path;
    foreach (@paths) {
        s|%(\w+)%|$ENV{$1}//''|ge;
        next unless -e;
        $path = $_;
        last;
    }
    $path = rel2abs $path if $path;
    return $path;
}

1;