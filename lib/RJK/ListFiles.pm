package RJK::ListFiles;

use strict;
use warnings;

use RJK::Files;

sub traverse {
    my ($self, $listFile, $visitor, $opts) = @_;
    foreach my $path (@{$self->getPaths($listFile)}) {
        RJK::Files->traverse($path, $visitor, $opts);
    }
}

sub getPaths {
    my ($self, $file) = @_;

    open (my $fh, '<', $file) || die "$!: $file";
    my @paths = <$fh>;
    close $fh;

    chomp @paths;
    return wantarray ? @paths : \@paths;
}

sub getDirs {
    my ($self, $file) = @_;
    my @paths = grep { $self->isDir($_) } @{$self->getPaths($file)};
    return wantarray ? @paths : \@paths;
}

sub getFiles {
    my ($self, $file) = @_;
    my @paths = grep { ! $self->isDir($_) } @{$self->getPaths($file)};
    return wantarray ? @paths : \@paths;
}

sub isDir {
    substr($_[1], -1) eq "\\";
}

1;
