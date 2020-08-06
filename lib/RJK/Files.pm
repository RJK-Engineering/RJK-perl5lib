package RJK::Files;

use strict;
use warnings;

use RJK::File::Paths;
use RJK::File::Stat;
use RJK::TreeVisitResult qw(matchesTreeVisitResult :constants);

# Subdirectories are visited after all files in the directory have been visited.

sub traverse {
    my ($class, $path, $visitor, $opts) = @_;

    $path = RJK::File::Paths::get($path);
    my $stat = RJK::File::Stat::get($path->{path});

    if (! $stat) {
        $visitor->visitFileFailed($path, "Stat failed");
    } elsif ($stat->{isDir}) {
        $class->traverseDir($path, $visitor, $opts, $stat);
    } elsif ($stat->{isFile}) {
        $visitor->visitFile($path, $stat);
    }
}

sub traverseDir {
    my ($class, $dir, $visitor, $opts, $dirStat) = @_;

    if (my $entries = $class->getEntries($dir->{path})) {
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

        $visitor->preVisitDir($dir, $dirStat, \@files, \@dirs);

        foreach (@files) {
            my ($file, $stat) = @$_;
            if ($stat) {
                $visitor->visitFile($file, $stat);
            } else {
                $visitor->visitFileFailed($file, "Stat failed");
            }
        }

        $visitor->postVisitFiles($dir, $dirStat, \@files, \@dirs);

        foreach (@dirs) {
            my ($dir, $stat) = @$_;
            $class->traverseDir($dir, $visitor, $opts, $stat);
        }

        $visitor->postVisitDir($dir, $dirStat, \@files, \@dirs);
    } else {
        $visitor->visitFileFailed($dir, "Readdir failed");
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
