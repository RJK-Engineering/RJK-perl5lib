package RJK::Path;

use strict;
use warnings;
no warnings 'redefine';

use RJK::Paths;

our $separator;
our $currentDirName;
our $parentDirName;

my $trailingDotsRegex = qr{ \.+ $ }x;

sub normalize {
    my $path = shift->{path};
    my (@normalized, $updir);
    $updir = 0;

    foreach my $name (reverse split /\Q$separator\E/, $path) {
        ++$updir && next if $name eq $parentDirName;
        $updir-- && next if $updir;
        next if $name eq $currentDirName;

        $name =~ s/$trailingDotsRegex//;    # remove trailing dots, java.nio.file.Path does not do this
        unshift @normalized, $name;
    }
    $path = join $separator, @normalized;

    return RJK::Paths->get($path);
}

1;
