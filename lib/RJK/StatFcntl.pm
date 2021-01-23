package RJK::Stat;

use strict;
use warnings;
no warnings 'redefine';

use Fcntl ':mode';

sub get {
    my ($self, $path) = @_;
    return bless [ stat $path ], $self;
}

sub isReadable   { $_[0][2] & S_IRUSR }
sub isWritable   { $_[0][2] & S_IWUSR }
sub isExecutable { $_[0][2] & S_IXUSR }
sub isDir        { ($_[0][2] & S_IFMT) == S_IFDIR }
sub isFile       { ($_[0][2] & S_IFMT) != S_IFDIR }
sub isRegular    { ($_[0][2] & S_IFMT) == S_IFREG }
sub isBlock      { ($_[0][2] & S_IFMT) == S_IFBLK }
sub isCharacter  { ($_[0][2] & S_IFMT) == S_IFCHR }

1;
