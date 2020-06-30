package RJK::File::Stat;

use strict;
use warnings;

sub get {
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

1;
