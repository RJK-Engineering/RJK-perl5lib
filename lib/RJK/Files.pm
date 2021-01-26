###############################################################################
=begin TML

---+ package RJK::Files

=cut
###############################################################################

package RJK::Files;

use strict;
use warnings;

use FileVisitResult;
use RJK::Paths;
use RJK::Stat;

###############################################################################
=begin TML

---++ Class methods

---+++ traverse($path, $visitor, %opts) -> $terminated
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

SKIP_FILES    skips file2
SKIP_DIRS     skips dir2
SKIP_SUBTREE  skips dir2, file2
SKIP_SIBLINGS skips dir2, file2, dir3
</verbatim>

=cut
###############################################################################

sub traverse {
    my ($self, $path, $visitor, $opts, $stats) = @_;
    my $result;
    if ($stats) {
        &traverseWithStats;
        $result = $stats->{result};
    } else {
        $result = &_traverse;
    }
    return FileVisitResult->matches($result, FileVisitResult::TERMINATE);
}

sub _traverse {
    my ($self, $path, $visitor, $opts) = @_;
    $visitor = createSimpleFileVisitor($visitor) if ! UNIVERSAL::isa($visitor, 'RJK::FileVisitor');
    $path = RJK::Paths->get($path);
    my $stat = RJK::Stat->get($path->{path});

    $_ = $path->{path};
    if (! $stat) {
        return $visitor->visitFileFailed($path, "Stat failed");
    } elsif ($stat->isDir) {
        return $self->traverseDir($path, $visitor, $opts, $stat, 0);
    } elsif ($stat->isFile) {
        return $visitor->visitFile($path, $stat);
    }
}

sub createSimpleFileVisitor {
    require RJK::SimpleFileVisitor;
    new RJK::SimpleFileVisitor($_[0]);
}

sub traverseWithStats {
    require RJK::Files::TraverseWithStats;
    &traverseWithStats;
}

sub createStats {
    require RJK::Files::TraverseWithStats;
    &createStats;
}

sub traverseDir {
    my ($self, $dir, $visitor, $opts, $dirStat, $depth) = @_;
    my ($result, $skipFiles, $skipDirs);
    $skipDirs = 1 if defined $opts->{maxDepth} && $depth == $opts->{maxDepth};

    my $entries = $self->getEntries($dir->{path});
    return $visitor->visitFileFailed($dir, "$!") if not defined $entries;

    $result = $visitor->preVisitDir($dir, $dirStat);
    if (FileVisitResult->matches($result,
        FileVisitResult::TERMINATE, FileVisitResult::SKIP_SUBTREE, FileVisitResult::SKIP_SIBLINGS
    )) {
        return $result;
    } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_FILES)) {
        $skipFiles = 1;
    } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_DIRS)) {
        $skipDirs = 1;
    }

    my (@dirs, @files);
    foreach (@$entries) {
        my $child = RJK::Paths->get($dir->{path}, $_);
        my $stat = RJK::Stat->get($child->{path});
        if (! $stat) {
            push @files, [ $child ] unless $skipFiles;
        } elsif ($stat->isDir) {
            push @dirs, [ $child, $stat ] unless $skipDirs;
        } elsif ($stat->isFile) {
            push @files, [ $child, $stat ] unless $skipFiles;
        }
    }

    if ($opts->{sort}) {
        @files = sort {
            $a->[0]{name} cmp $b->[0]{name};
        } @files;
    }

    foreach (@files) {
        my ($file, $stat) = @$_;
        $_ = $file->{path};
        if ($stat) {
            $result = $visitor->visitFile($file, $stat);
        } else {
            $result = $visitor->visitFileFailed($file, "Stat failed");
        }
        if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
            return FileVisitResult::TERMINATE;
        } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
            return $visitor->postVisitDir($dir, $dirStat);
        } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_DIRS)) {
            @dirs = ();
        } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_FILES)) {
            last;
        }
    }

    $_ = $dir->{path};
    $result = $visitor->postVisitFiles($dir, $dirStat);
    if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
        return FileVisitResult::TERMINATE;
    } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
        return $visitor->postVisitDir($dir, $dirStat);
    } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_DIRS)) {
        @dirs = ();
    }

    foreach (@dirs) {
        my ($dir, $stat) = @$_;
        $_ = $dir->{path};
        $result = $self->traverseDir($dir, $visitor, $opts, $stat, $depth+1);
        if (FileVisitResult->matches($result, FileVisitResult::TERMINATE)) {
            return FileVisitResult::TERMINATE;
        } elsif (FileVisitResult->matches($result, FileVisitResult::SKIP_SIBLINGS)) {
            last;
        }
    }

    $_ = $dir->{path};
    return $visitor->postVisitDir($dir, $dirStat);
}

sub getEntries {
    my ($self, $dir) = @_;
    opendir my $dh, $dir or return;

    my @entries = grep {
        !/^\.\.?$/ &&
        !/[^\\]\\System Volume Information$/
    } readdir $dh;

    closedir $dh;
    return \@entries;
}

1;
