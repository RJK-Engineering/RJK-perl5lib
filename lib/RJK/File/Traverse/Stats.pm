package RJK::File::Traverse::Stats;

use strict;
use warnings;

use RJK::File::DirStats;
use RJK::File::TraverseStats;
use RJK::File::Visitor;
use RJK::IO::File;
use RJK::IO::AltStat;

sub new {
    my $self = bless {}, shift;
    $self->{visitor} = &RJK::File::Visitor::getVisitor || new RJK::File::Visitor;
    $self->{stats} = new RJK::File::TraverseStats();

    my %opts = @_;
    $self->{filter} = $opts{filter} || sub {1};
    $self->{sort} = $opts{sort};
    $self->{maxDepth} = $opts{maxDepth} // 99;

    # I/O functions
    $self->{readdir} = $opts{readdir} || \&readdir;
    $self->{stat} = $opts{stat} || \&stat;

    return $self;
}

sub stats {
    $_[0]->{stats};
}

sub traverse {
    my $self = shift;
    my $file = &RJK::IO::RJK::File::getFile || die "Insufficient arguments";
    my $visitor = &RJK::File::Visitor::getVisitor || $self->{visitor};
    shift if @_ % 2; # options after first arg in uneven sized list
    my %opts = @_;

    $opts{filter} //= $self->{filter};
    $opts{sort} //= $self->{sort};
    $opts{maxDepth} //= $self->{maxDepth};

    $self->{stats}->startTraverse();

    if (! $self->{stat}->($file)) {
        local $_ = $file->{path};
        $visitor->visitFileFailed($file, "Stat failed");
    } elsif ($file->{isDir}) {
        $self->_recursive($file, $visitor,
            $opts{filter}, $opts{sort}, $opts{maxDepth});
    } else { # visit parent dir and file
        my $dir = $file->parent;
        local $_ = $dir->{path};

        if (! $self->{stat}->($dir)) {
            $visitor->postVisitDir($dir, "Stat failed");
        } else {
            $visitor->preVisitDir($dir, [$file]);
            local $_ = $file->{path};

            if ($self->{stat}->($file)) {
                $visitor->visitFile($file);
                $self->{stats}->addFile($file);

                # set stats
                $dir->{stats} = new RJK::File::DirStats();
                $dir->{stats}->addFile($file);
                $dir->{cumulative} = $dir->{stats}->clone();
                local $_ = $dir->{path};

                $visitor->postVisitDir($dir);
                $self->{stats}->addDir;
            } else {
                $visitor->visitFileFailed($file, "Stat failed");
                $self->{stats}->addFailed;
            }
        }
    }

    $self->{stats}->stopTraverse();
}

sub _recursive {
    my ($self, $dir, $visitor, $filter, $sort, $maxDepth) = @_;
    $dir->{stats} = new RJK::File::DirStats();

    # load dir
    my $entries = $self->{readdir}->($dir);
    unless ($entries) {
        local $_ = $dir->{path};
        $visitor->postVisitDir($dir, "Readdir failed");
        return;
    }

    my (@files, @dirs, @skipped, @failed);
    foreach (@$entries) {
        my $file = $dir->getChild($_);

        $self->{stat}->($file);
        if (! $file->{exists}) {
            unless (RJK::IO::AltStat::stat($file)) {
                push @failed, $file;
                die $file->{path};
                next;
            }
        }

        if (! $filter->($file)) {
            push @skipped, $file;
            next;
        }

        if ($file->{isDir}) {
            push @dirs, $file;
        } else {
            push @files, $file;
            $dir->{stats}{size} += $file->{size};
        }
    }
    $dir->{stats}{dirs} = @dirs;
    $dir->{stats}{files} = @files;
    $dir->{stats}{total} = @dirs + @files;
    $dir->{cumulative} = $dir->{stats}->clone();

    # sort files
    @files = sort {
        $sort->($a, $b);
    } @files if $sort;

    # pre visit dir
    local $_ = $dir->{path};
    $visitor->preVisitDir($dir, \@files, \@dirs, \@skipped, \@failed);

    # visit files
    foreach my $file (@files) {
        $_ = $file->{path};
        $visitor->visitFile($file);
        $self->{stats}->addFile($file);
    }
    foreach my $file (@failed) {
        $_ = $file->{path};
        $visitor->visitFileFailed($file, "Stat failed");
        $self->{stats}->addFailed;
    }

    # post visit dir
    $_ = $dir->{path};
    $visitor->postVisitDir($dir);
    $self->{stats}->addDir;

    # traverse subdirs
    foreach my $subdir (@dirs) {
        if ($self->{stats}{level} < $maxDepth) {
            $self->{stats}{level}++;
            $self->_recursive($subdir, $visitor, $filter, $sort, $maxDepth);
            $dir->{cumulative}->add($subdir->{cumulative});
            $self->{stats}{level}--;
        }
    }
}

#### functions performing I/O

sub readdir {
    opendir DIR, shift->{path} or return;

    my @entries = grep {
        $_ ne $RJK::IO::RJK::File::curdir && $_ ne $RJK::IO::RJK::File::updir &&
        !/[^\\]\\System Volume Information$/
    } CORE::readdir DIR;
    closedir DIR;

    return \@entries;
}

sub stat {
    return shift->stat;
}

1;
