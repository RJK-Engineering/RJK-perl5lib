package RJK::Filecheck::DirLists;

use strict;
use warnings;

use RJK::Filecheck::Config;
use RJK::Filecheck::VirtualPath;
use RJK::Paths;

sub traverse {
    my ($self, $list, $callback) = @_;

    my $dir = RJK::Filecheck::Config->get('dirlist.dir');
    my $file = "$dir\\$list";
    open my $fh, '<', $file or die "$!: $file";

    while (<$fh>) {
        chomp;
        /(.+):(.+)/;
        my $vpath = bless RJK::Paths->get("L:$2"), 'RJK::Filecheck::VirtualPath';
        $vpath->{path} = $_;
        $vpath->{label} = $1;
        $vpath->{relative} = $2;
        return if $callback->($vpath);
    }
    close $fh;
}

1;
