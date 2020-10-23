package RJK::File::Path::Util;

use strict;
use warnings;

use Exception::Class('Exception');
use File::Path ();

sub checkdir {
    my ($dir) = @_;
    if (-e $dir) {
        unless (-d $dir) {
            throw Exception("Not a directory: $dir");
        }
        return 0;
    }
    unless (File::Path::make_path $dir) {
        throw Exception("$!: $dir");
    }
    return 1;
}

1;
