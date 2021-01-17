package RJK::TotalCmd::DiskDirStat;
use parent 'RJK::Stat';

use strict;
use warnings;

sub get { ... }

sub new {
    return bless {}, shift;
}

sub exists       {}
sub isReadable   {}
sub isWritable   {}
sub isExecutable {}
sub size         { $_[0]{size} }
sub accessed     {}
sub modified     { $_[0]{modified} }
sub created      {}
sub isDir        { $_[0]{isDir} }
sub isFile       {}
sub isRegular    {}
sub isBlock      {}
sub isCharacter  {}

1;
