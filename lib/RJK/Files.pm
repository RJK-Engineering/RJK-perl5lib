package RJK::Files;

use strict;
use warnings;

use RJK::File::Paths;
use RJK::File::Stat;

sub Traverse {
    my ($path, $visitor, $opts) = @_;

    $path = RJK::File::Paths::get($path);
    my $stat = RJK::File::Stat::get($path->{path});

    if (! $stat) {
        local $_ = $path->{path};
        $visitor->visitFileFailed($path, "Stat failed");
    } elsif ($stat->{isDir}) {
        TraverseDir($path, $visitor, $opts, $stat);
    } elsif ($stat->{isFile}) {
        local $_ = $path->{path};
        $visitor->visitFile($path, $stat);
    }
}

sub TraverseDir {
    my ($dir, $visitor, $opts, $stat) = @_;

    if (my $entries = GetEntries($dir->{path})) {
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

        local $_ = $dir->{path};
        $visitor->preVisitDir($dir, $stat, \@files, \@dirs);

        foreach (@files) {
            my ($file, $stat) = @$_;
            local $_ = $file->{path};
            if ($stat) {
                $visitor->visitFile($file, $stat);
            } else {
                $visitor->visitFileFailed($file, "Stat failed");
            }
        }

        local $_ = $dir->{path};
        $visitor->postVisitFiles($dir, $stat, \@files, \@dirs);

        foreach (@dirs) {
            my ($dir, $stat) = @$_;
            TraverseDir($dir, $visitor, $stat);
        }

        local $_ = $dir->{path};
        $visitor->postVisitDir($dir, undef, \@files, \@dirs);
    } else {
        local $_ = $dir->{path};
        $visitor->visitFileFailed($dir, "Readdir failed");
    }
}

sub GetEntries {
    my $dir = shift;
    opendir my $dh, $dir or return;

    my @entries = grep {
        !/^\.\.?$/ &&
        !/[^\\]\\System Volume Information$/
    } readdir $dh;

    closedir $dh;
    return \@entries;
}

1;
