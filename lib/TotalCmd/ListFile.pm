package TotalCmd::ListFile;

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my $file = shift;
    $self->load($file) if $file;
    return $self;
}

sub load {
    my ($self, $file) = @_;

    open (my $fh, '<', $file) || die("$!: $file");
    my @paths = <$fh>;
    close $fh;
    chomp @paths;

    my (@dirs, @files);
    foreach (@paths) {
        if (substr($_, -1) eq "\\") {
            push @dirs, $_;
        } else {
            push @files, $_;
        }
    }
    $self->{paths} = \@paths;
    $self->{dirs} = \@dirs;
    $self->{files} = \@files;

    return 1;
}

sub paths {
    my $self = shift;
    return @{$self->{paths}};
}

sub dirs {
    my $self = shift;
    return @{$self->{dirs}};
}

sub files {
    my $self = shift;
    return @{$self->{files}};
}

1;
