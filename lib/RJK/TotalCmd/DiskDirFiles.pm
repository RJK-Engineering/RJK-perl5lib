###############################################################################
=begin TML

---+ package RJK::TotalCmd::DiskDirFiles

=cut
###############################################################################

package RJK::TotalCmd::DiskDirFiles;

use strict;
use warnings;

use Exceptions;
use OpenFileException;

use FileVisitResult;
use RJK::TotalCmd::DiskDirFile;
use RJK::TotalCmd::DiskDirStat;
use RJK::Path;
use RJK::Paths;

###############################################################################
=pod

---+++ RJK::TotalCmd::DiskDirFiles::traverse($path, $visitor, %opts) -> $terminated
   * =$path= - path to DiskDirFile.
   * =$visitor= - =RJK::FileVisitor= object.
   * =%opts= - option hash.
      * =$opts{nostat}= - do not include size and date fields (faster).
   * =$terminated= - true if traversal was terminated, false otherwise.

=cut
###############################################################################

sub traverse {
    my ($class, $path, $visitor, $opts) = @_;

    open my $fh, '<', $path
        or throw OpenFileException(error => "$!", file => $path, mode => '<');

    my ($root, $dir, $result, $skip);
    my $stat = new RJK::TotalCmd::DiskDirStat;
    $stat->{isDir} = 1;
    while (<$fh>) {
        chomp;
        my $fields = [ split /\t/ ];

        if ($fields->[0] =~ s/\\$//) {
            if (defined $skip) {
                next if "$root$fields->[0]" =~ /^$skip/;
                $skip = undef;
            }

            if ($dir) {
                $result = $visitor->postVisitFiles($dir, $stat);

                if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
                    return 1;
                } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
                    $skip = quotemeta($dir->parent || $dir->{path});
                }

                $result = $visitor->postVisitDir($dir, $stat);

                if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
                    return 1;
                } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
                    $skip = quotemeta($dir->parent || $dir->{path});
                }
            }

            if (@$fields > 1) {
                $dir = RJK::Paths->get($root, $fields->[0]);
                if (! $opts->{nostat}) {
                    $stat->{modified} = RJK::TotalCmd::DiskDirFile::parse_datetime("$fields->[2] $fields->[3]");
                }
            } else {
                $dir = RJK::Paths->get($fields->[0]);
                $root = $dir->{path};
            }

            $result = $visitor->preVisitDir($dir, $stat);

            if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
                return 1;
            } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SUBTREE)) {
                $skip = quotemeta $dir->{path};
            } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
                $skip = quotemeta($dir->parent || $dir->{path});
                $dir = undef; # don't postVisitFiles()
                next;
            }

            $result = $visitor->preVisitFiles($dir, $stat);

            if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
                return 1;
            } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SUBTREE)) {
                $skip = quotemeta $dir->{path};
            } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
                $skip = quotemeta($dir->parent || $dir->{path});
                $dir = undef; # don't postVisitFiles()
            }
        } else {
            next if defined $skip;

            my $dirpath = $dir ? $dir->{path} : '';
            my $file = RJK::Paths->get($dirpath, $fields->[0]);

            my $stat;
            if (! $opts->{nostat}) {
                $stat = new RJK::TotalCmd::DiskDirStat;
                $stat->{size} = $fields->[1];
                $stat->{modified} = ! $opts->{nostat} && RJK::TotalCmd::DiskDirFile::parse_datetime("$fields->[2] $fields->[3]");
            }

            $result = $visitor->visitFile($file, $stat);

            if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
                return 1;
            } elsif ($dir && FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
                $skip = quotemeta $dir->{path};
            }
        }
    }

    if ($dir) {
        $result = $visitor->postVisitFiles($dir, $stat);
        $result = $visitor->postVisitDir($dir, $stat);
    }
    return FileVisitResult->matches($result, FileVisitResult::TERMINATE);
}

1;
