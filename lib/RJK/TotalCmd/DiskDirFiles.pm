=begin TML

---+ package RJK::TotalCmd::DiskDirFiles

=cut

package RJK::TotalCmd::DiskDirFiles;

use strict;
use warnings;

use File::Spec::Functions qw(catdir catfile splitdir splitpath);

use RJK::File::Exceptions;
use RJK::TotalCmd::DiskDirFile;
use RJK::TreeVisitResult qw(matchesTreeVisitResult :constants);
use RJK::File::Paths;

sub traverse {
    my ($class, $path, $visitor, $opts) = @_;

    open my $fh, '<', $path
        or throw RJK::File::OpenFileException(error => "$!", file => $path, mode => '<');

    my $root = <$fh>;
    chomp $root;
    $root =~ s/\\$//;

    my $dir = RJK::File::Paths::get($root);
    my $stat = { modified => '' };

    my $result = $visitor->preVisitDir($dir, $stat);

    return if matchesTreeVisitResult($result, TERMINATE, SKIP_SIBLINGS, SKIP_SUBTREE);

    my $skip;
    while (<$fh>) {
        chomp;
        my $fields = [ split /\t/ ];

        if ($fields->[0] =~ s/\\$//) {
            if (defined $skip) {
                next if $fields->[0] =~ /^$skip/;
                $skip = undef;
            }

            $result = $visitor->postVisitDir($dir);

            if (matchesTreeVisitResult($result, TERMINATE)) {
                last;
            } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                $skip = quotemeta $dir->{dir};
            }

            $dir = RJK::File::Paths::get($root, $fields->[0]);
            unless ($opts->{quick}) {
                $stat = {
                    modified => RJK::TotalCmd::DiskDirFile::parse_datetime("$fields->[2] $fields->[3]")
                }
            }

            $result = $visitor->preVisitDir($dir, $stat);

            if (matchesTreeVisitResult($result, TERMINATE)) {
                last;
            } elsif (matchesTreeVisitResult($result, SKIP_SUBTREE)) {
                $skip = quotemeta $dir->{path};
            } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                $skip = quotemeta $dir->{dir};
            }
        } else {
            next if defined $skip;

            my $file = RJK::File::Paths::get($root, $fields->[0]);
            unless ($opts->{quick}) {
                $stat = {
                    size => $fields->[1],
                    modified => ! $opts->{quick} && RJK::TotalCmd::DiskDirFile::parse_datetime("$fields->[2] $fields->[3]"),
                }
            }

            $result = $visitor->visitFile($file, $stat);

            if (matchesTreeVisitResult($result, TERMINATE)) {
                last;
            } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                $skip = quotemeta $dir->{path};
            }
        }
    }

    $result = $visitor->postVisitDir($dir);
}

1;
