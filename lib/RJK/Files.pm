package RJK::Files;

use strict;
use warnings;

use File::Spec::Functions qw(canonpath splitpath catpath catdir);

sub Traverse {
    my ($path, $visitor, $opts) = @_;

    $path = GetPath($path);
    my $stat = GetStat($path->{path});

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

    my $entries = GetEntries($dir->{path});
    if ($entries) {
        my (@dirs, @files);
        foreach (@$entries) {
            my $child = GetPath(catdir($dir->{path}, $_));
            my $stat = GetStat($child->{path});
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

sub GetPath {
    my $path = shift;

    my ($volume, $directories, $file) = splitpath(canonpath($path));
    my ($basename, $extension) = ($file =~ /^(.+)\.([^\.]+)$/);

    return {
        path => $path,
        dir => catpath($volume, $directories, ''),
        name => $file,
        volume => $volume,
        directories => $directories,
        basename => $basename,
        extension => $extension // ''
    };
}

sub GetStat {
    my $path = shift;

    my @stat = stat $path;
    return if ! @stat;

    return {
        exists => 1,
        isDir => -d _,
        isFile => -f _,
        isReadable => -r _,
        isWritable => -w _,
        isExecutable => -x _,
        size => $stat[7],
        accessed => $stat[8],
        modified => $stat[9],
        created => $stat[10],
        #~ isLink => -l $path # updates stat buffer, don't use _ for this file hereafter!
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
