package RJK::Path::Util;

use strict;
use warnings;

use File::Path ();
use RJK::File::Exceptions;

sub checkdir {
    my ($self, $dir) = @_;
    if (-e $dir) {
        return if -d $dir;
        throw RJK::FileException(error => "Not a directory: $dir", file => $dir);
    }

    File::Path::make_path $dir, {error => \my $err};
    return if ! $err || ! @$err;

    my ($file, $message) = %{$err->[0]};
    throw Exception($message) if $file eq '';
    throw RJK::FileException(error => $message, file => $file);
}

1;
