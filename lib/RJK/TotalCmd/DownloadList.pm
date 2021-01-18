###############################################################################
=begin TML

---+ package RJK::TotalCmd::DownloadList

---++ From Total Commander help

Edit list file
If you have used the command "FTP download from list",
the background transfer manager reads the list of files to be
transferred from a list file. With this command, you can add further
operations to the list file. If you add them to the end of the file,
the background transfer manager will add them automatically to the
queue. The list must be saved either as ANSI (plain text) or UTF-8
(with byte order marker BOM at the beginning).

FTP Download from list
Downloads all files from a user-created list file to the given
directory. The list file must contain a list of URLs to files or
subdirs (like ftp://ftp.server.com/subdir/file.zip). It may also
contain a relative or absolute destination name, separated by an arrow
(ftp://ftp.server.com/subdir/file.zip -> c:\local\file.zip). You can
add a file to the download list by right clicking on it during an ftp
connection, and choosing 'add to download list'. This function also
allows to download from WEB servers (http//www.server.com). The list
must be saved either as ANSI (plain text) or UTF-8 (with byte order
marker BOM at the beginning).

=cut
###############################################################################

package RJK::TotalCmd::DownloadList;

use strict;
use warnings;

###############################################################################
=pod

---++ Object creation

---+++ new($file) -> RJK::TotalCmd::DownloadList
   * =$file= - Path to list file.
Returns a new =RJK::TotalCmd::DownloadList= object.

---+++ list() -> @list or \@list
Returns download list as a list of strings.

---+++ add($operation, $source, [$destination])
   * =$operation= - ="copy"= or ="move"=.
   * =$source= - Path to file or directory.
   * =$destination= - Optional, must be a file name and not a directory name.

---+++ addCopy($source, [$destination])
Same as =add("copy", $source, $destination)=.

---+++ addMove($source, [$destination])
Same as =add("move", $source, $destination)=.

---+++ addFlags($flags)
Add copy flags.

---+++ addClearFlags()
Same as =addFlags("0")=.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{file} = shift;
    $self->{list} = [];
    return $self;
}

sub list {
    my ($self) = @_;
    wantarray ? @{$self->{list}} : $self->{list};
}

sub add {
    my ($self, $operation, $source, $destination) = @_;
    die if $operation ne "copy" and $operation ne "move";
    my $entry = "$operation:$source";
    $entry .= " -> $destination" if $destination;
    push @{$self->{list}}, $entry;
}

sub addCopy {
    my ($self, $source, $destination) = @_;
    $self->add("copy", $source, $destination);
}

sub addMove {
    my ($self, $source, $destination) = @_;
    $self->add("move", $source, $destination);
}

sub addFlags {
    my ($self, $flags) = @_;
    push @{$self->{list}}, "copyflags:$flags";
}

sub addClearFlags {
    my ($self) = @_;
    push @{$self->{list}}, "copyflags:0";
}

###############################################################################
=pod

---++ File access

---+++ read([$path]) -> RJK::TotalCmd::DownloadList
Read data from file. Returns false on failure, callee on success.

---+++ write([$path]) -> RJK::TotalCmd::DownloadList
Write data to file. Returns false on failure, callee on succes.

---+++ append($file)
   * =$file= - path to file to append to.

=cut
###############################################################################

sub read {
    my ($self, $file) = @_;
    $file //= $self->{file};
    open (my $fh, '<', $file) || return;
    while (<$fh>) {
        chomp;
        push @{$self->{list}}, $_;
    }
    close $fh || return;
    return $self;
}

sub write {
    my ($self, $file) = @_;
    $file //= $self->{file};
    open (my $fh, '>', $file) || return;
    foreach (@{$self->{list}}) {
        print $fh "$_\n" || return;
    }
    close $fh || return;
    return $self;
}

sub append {
    my ($self, $file) = @_;
    open (my $fh, ">>$file") || return;
    foreach (@{$self->{list}}) {
        print $fh "$_\n";
    }
    close $fh;
}

1;
