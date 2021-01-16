package RJK::Files;

use strict;
use warnings;

use RJK::File::Paths;
use RJK::File::Stat;
use RJK::File::TreeVisitResult qw(matchesTreeVisitResult :constants);

###############################################################################
=begin TML

---+++ RJK::Files::traverse($path, $visitor, %opts) -> $terminated
   * =$path= - path to dir or file.
   * =$visitor= - =RJK::FileVisitor= object.
   * =%opts= - option hash.
      * =$opts{sort}= - sort by name if set to true.
   * =$terminated= - true if traversal was terminated, false otherwise.

Subdirectories are visited after all files in the directory have been visited.

---++++ Examples

<verbatim>
       root
      /  |  \
  file1 dir1 dir3
        /  \
     dir2  file2

RJK::FileVisitor methods called when Files.traverse("root") is called:

preVisitDir("root")
visitFile("root/file1")
postVisitFiles("root")
    preVisitDir("root/dir1")
    visitFile("root/dir1/file2")
    postVisitFiles("root/dir1")
        preVisitDir("root/dir1/dir2")
        postVisitFiles("root/dir1/dir2")
        postVisitDir("root/dir1/dir2")
    postVisitDir("root/dir1")
    preVisitDir("root/dir3")
    postVisitFiles("root/dir3")
    postVisitDir("root/dir3")
postVisitDir("root")

Skipped files/dirs for different TreeVisitResults when preVisitDir("dir1") is called:

SKIP_FILES       skips file2
SKIP_DIRECTORIES skips dir2
SKIP_SUBTREE     skips dir2, file2
SKIP_SIBLINGS    skips dir2, file2, dir3
</verbatim>

=cut
###############################################################################

sub traverse {
    my ($class, $path, $visitor, $opts) = @_;
    my $result;

    $path = RJK::File::Paths::get($path);
    my $stat = RJK::File::Stat::get($path->{path});

    if (! $stat) {
        $result = $visitor->visitFileFailed($path, "Stat failed");
    } elsif ($stat->{isDir}) {
        $result = $class->traverseDir($path, $visitor, $opts, $stat);
    } elsif ($stat->{isFile}) {
        $result = $visitor->visitFile($path, $stat);
    }

    return matchesTreeVisitResult($result, TERMINATE);
}

sub traverseDir {
    my ($class, $dir, $visitor, $opts, $dirStat) = @_;
    my $result;

    if (my $entries = $class->getEntries($dir->{path})) {
        $result = $visitor->preVisitDir($dir, $dirStat);
        if (matchesTreeVisitResult($result, TERMINATE, SKIP_SUBTREE, SKIP_SIBLINGS)) {
            return $result;
        }

        my (@dirs, @files);
        foreach (@$entries) {
            my $child = RJK::File::Paths::get($dir->{path}, $_);
            my $stat = RJK::File::Stat::get($child->{path});
            if (! $stat) {
                push @files, [ $child ];
            } elsif ($stat->{isDir}) {
                push @dirs, [ $child, $stat ];
            } elsif ($stat->{isFile}) {
                push @files, [ $child, $stat ];
            }
        }

        if ($opts->{sort}) {
            @files = sort {
                $a->[0]{name} cmp $b->[0]{name};
            } @files;
        }

        foreach (@files) {
            my ($file, $stat) = @$_;
            if ($stat) {
                $result = $visitor->visitFile($file, $stat);
            } else {
                $result = $visitor->visitFileFailed($file, "Stat failed");
            }
            if (matchesTreeVisitResult($result, TERMINATE)) {
                return TERMINATE;
            } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                return $visitor->postVisitDir($dir, $dirStat);
            }
        }

        $result = $visitor->postVisitFiles($dir, $dirStat);
        if (matchesTreeVisitResult($result, TERMINATE)) {
            return TERMINATE;
        } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
            return $visitor->postVisitDir($dir, $dirStat);
        }

        foreach (@dirs) {
            my ($dir, $stat) = @$_;
            $result = $class->traverseDir($dir, $visitor, $opts, $stat);
            if (matchesTreeVisitResult($result, TERMINATE)) {
                return TERMINATE;
            } elsif (matchesTreeVisitResult($result, SKIP_SIBLINGS)) {
                last;
            }
        }

        return $visitor->postVisitDir($dir, $dirStat);
    } else {
        return $visitor->visitFileFailed($dir, "Readdir failed");
    }
}

sub getEntries {
    my ($class, $dir) = @_;
    opendir my $dh, $dir or return;

    my @entries = grep {
        !/^\.\.?$/ &&
        !/[^\\]\\System Volume Information$/
    } readdir $dh;

    closedir $dh;
    return \@entries;
}

1;
