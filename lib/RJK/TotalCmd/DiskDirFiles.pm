=begin TML

---+ package RJK::TotalCmd::DiskDirFiles

=cut
###############################################################################

package RJK::TotalCmd::DiskDirFiles;

use strict;
use warnings;

use RJK::File::Exceptions;
use RJK::TotalCmd::DiskDirFile;
use RJK::TreeVisitResult qw(matchesTreeVisitResult :constants);
use RJK::File::Paths;

###############################################################################
=pod

---+++ RJK::TotalCmd::DiskDirFiles::traverse($path, $visitor, %opts) -> $terminated
   * =$path= - path to DiskDirFile.
   * =$visitor= - =RJK::FileVisitor= object.
   * =%opts= - option hash.
      * =$nostat= - do not include size and date fields (faster).
   * =$terminated= - true if traversal was terminated, false otherwise.

=cut
###############################################################################

sub traverse {
    my ($class, $path, $visitor, $opts) = @_;

    open my $fh, '<', $path
        or throw RJK::File::OpenFileException(error => "$!", file => $path, mode => '<');

    my ($root, $dir, $stat, $result, $skip);
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

                if (matchesTreeVisitResult($result, TERMINATE)) {
                    return 1;
                } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                    $skip = quotemeta($dir->{dir} || $dir->{path});
                }
            }

            if (@$fields > 1) {
                $dir = RJK::File::Paths::get($root, $fields->[0]);
                if (! $opts->{nostat}) {
                    $stat->{modified} = RJK::TotalCmd::DiskDirFile::parse_datetime("$fields->[2] $fields->[3]");
                }
            } else {
                $dir = RJK::File::Paths::get($fields->[0]);
                $root = $dir->{path};
            }

            $result = $visitor->preVisitFiles($dir, $stat);

            if (matchesTreeVisitResult($result, TERMINATE)) {
                return 1;
            } elsif (matchesTreeVisitResult($result, SKIP_SUBTREE)) {
                $skip = quotemeta $dir->{path};
            } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                $skip = quotemeta($dir->{dir} || $dir->{path});
                $dir = undef; # don't postVisitFiles()
            }
        } else {
            next if defined $skip;

            my $dirpath = $dir ? $dir->{path} : '';
            my $file = RJK::File::Paths::get($dirpath, $fields->[0]);

            my $stat;
            if (! $opts->{nostat}) {
                $stat->{size} = $fields->[1];
                $stat->{modified} = ! $opts->{nostat} && RJK::TotalCmd::DiskDirFile::parse_datetime("$fields->[2] $fields->[3]");
            }

            $result = $visitor->visitFile($file, $stat);

            if (matchesTreeVisitResult($result, TERMINATE)) {
                return 1;
            } elsif ($dir && matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                $skip = quotemeta $dir->{path};
            }
        }
    }

    if ($dir) {
        $result = $visitor->postVisitFiles($dir, $stat);
    }
    return matchesTreeVisitResult($result, TERMINATE);
}

1;
