=begin TML

---+ package RJK::TotalCmd::DownloadList

=cut

package RJK::TotalCmd::DownloadList;

use strict;
use warnings;

use File::Spec::Functions qw(splitpath catfile);

###############################################################################
=pod

---++ Object creation

---+++ new($path) -> RJK::TotalCmd::DownloadList
Returns a new =RJK::TotalCmd::DownloadList= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{file} = shift;
    $self->{lines} = [];
    return $self;
}

sub lines {
    my ($self) = @_;
    wantarray ? @{$self->{lines}} : $self->{lines};
}

sub add {
    my ($self, $operation, $source, $dest) = @_;
    $dest = getDestination($source, $dest);
    push @{$self->{lines}}, "$operation:$source -> $dest";
}

sub getDestination {
    my ($source, $dest) = @_;
    if ($dest =~ /[\\\/]$/) {
        my ($volume, $directories, $file) = splitpath($source);
        $dest = catfile($dest, $file);
    }
    return $dest;
}

sub addMove {
    my ($self, $source, $dest) = @_;
    push @{$self->{lines}}, "move:$source -> $dest";
}

sub addCopy {
    my ($self, $source, $dest) = @_;
    push @{$self->{lines}}, "copy:$source -> $dest";
}

sub addCopyFlags {
    my ($self, $flags) = @_;
    push @{$self->{lines}}, "copyflags:$flags";
}

###############################################################################
=pod

---++ File access

---+++ read([$path]) -> RJK::TotalCmd::DownloadList
Read data from file. Returns false on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::DownloadList
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub read {
    my ($self, $file) = @_;
    $file //= $self->{file};
    open (my $fh, '<', $file) || return;
    while (<$fh>) {
        chomp;
        push @{$self->{lines}}, $_;
    }
    close $fh || return;
    return $self;
}

sub write {
    my ($self, $file) = @_;
    $file //= $self->{file};
    open (my $fh, '>', $file) || return;
    foreach (@{$self->{lines}}) {
        print $fh "$_\n" || return;
    }
    close $fh || return;
    return $self;
}

sub append {
    my ($self, $file) = @_;
    $file //= $self->{file};
    open (my $fh, ">>$file") || return;
    foreach (@{$self->{lines}}) {
        print $fh "$_\n";
    }
    close $fh;
}

1;
