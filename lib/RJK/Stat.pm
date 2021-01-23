package RJK::Stat;

use strict;
use warnings;

our $USE_FCNTL;

sub get {
    my ($self, $path) = @_;
    my @stat = stat $path;
    push @stat, -r _, -w _, -x _, -d _, -f _ if !$USE_FCNTL && @stat;
    require RJK::StatFcntl if $USE_FCNTL;
    return bless \@stat, $self;
}

sub exists       { @{$_[0]} > 0 }
sub size         { $_[0][7] }
sub accessed     { $_[0][8] }
sub modified     { $_[0][9] }
sub created      { $_[0][10] }

sub isReadable   { $_[0][13] }
sub isWritable   { $_[0][14] }
sub isExecutable { $_[0][15] }
sub isDir        { $_[0][16] }
sub isFile       { $_[0][17] }

1;
