package RJK::File::Path;

use strict;
use warnings;
no warnings 'redefine';

use RJK::File::Paths;

our $separator;

sub parent {
    $_[0]{name} eq '' ? '' : RJK::File::Paths::get($_[0]{volume} . ':' . $_[0]{directories});
}

sub root {
    RJK::File::Paths::get($_[0]{volume} . ':' . $separator);
}

sub driveletter {
    $_[0]{volume} . ':';
}

my $splitFilenameRegex = qr{ ^ (.+)\.(.+) $ }x;

sub basename {
    ($_[0]{name} =~ /$splitFilenameRegex/)[0] // $_[0]{name} // '';
}

sub extension {
    ($_[0]{name} =~ /$splitFilenameRegex/)[1] // '';
}

my $trailingDotsRegex = qr{ \.+ $ }x;

sub normalize {
    my $path = shift->{path};
    my (@normalized, $updir);
    $updir = 0;

    foreach my $name (reverse split /\Q$separator\E/, $path) {
        ++$updir && next if $name eq '..';
        $updir-- && next if $updir;
        next if $name eq '.';

        $name =~ s/$trailingDotsRegex//;    # remove trailing dots, java.nio.file.Path does not do this
        unshift @normalized, $name;
    }
    $path = join $separator, @normalized;

    return RJK::File::Paths::get($path);
}

1;
