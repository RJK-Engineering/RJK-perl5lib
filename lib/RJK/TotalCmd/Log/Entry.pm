package RJK::TotalCmd::Log::Entry;

use strict;
use warnings;

use Class::AccessorMaker {
    date => undef, time => undef,
    sourcedir => undef, sourcefile => undef, source => undef,
    targetdir => undef, targetfile => undef, target => undef,
    operation => undef, isFsPluginOp => undef,
    success => undef, error => undef, skipped => undef,
    user => undef, encoding => undef
};

sub isFileOp { defined $_[0]{success} // $_[0]{error} // $_[0]{skipped} }

sub isMoveOp { $_[0]{operation} eq 'Move' }
sub isCopyOp { $_[0]{operation} eq 'Copy' }
sub isDeleteOp { $_[0]{operation} eq 'Delete' }
sub isCreateFileOp { $_[0]{operation} eq 'CreateFile' }
sub isNewFolderOp { $_[0]{operation} eq 'NewFolder' }
sub isDeleteFolderOp { $_[0]{operation} eq 'DeleteFolder' }
sub isPackOp { $_[0]{operation} eq 'Pack' }
sub isUnpackOp { $_[0]{operation} eq 'Unpack' }
sub isShortcutOp { $_[0]{operation} eq 'Shortcut' }

sub isStartup { $_[0]{operation} eq 'Startup' }
sub isShutdown { $_[0]{operation} eq 'Shutdown' }

sub getOpMsg {
    my $self = shift;
    return $self->{error}
        || $self->{skipped} && "Skipped"
        || $self->{success} && "Success"
        || $self->{user} && ($self->{encoding} ? "$self->{user}, $self->{encoding}" : $self->{user})
        || "No message";
}

1;

__END__

A log entry is either a file operation or a program start or shutdown entry.
- When the entry is a file operation entry:
  - isFileOp() returns true
  - operation() returns "Move", "Copy", "Delete", "CreateFile", "NewFolder", "DeleteFolder", "Pack", "Unpack" or "Shortcut"
  - A file operation can be successfull, an error or skipped
    - When succesfull: success() returns true
    - When there was an error: error() returns the error message
    - When skipped: skipped() returns true
- When the entry is a program start entry:
  - operation() returns "Startup"
  - user() returns the associated user
  - encoding() returns the encoding or undef if not available
- When the entry is a program shutdown entry:
  - operation() returns "Shutdown"
  - user() returns the associated user
