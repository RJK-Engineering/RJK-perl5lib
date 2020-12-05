package RJK::File::Sidecar;

use strict;
use warnings;

use RJK::Files;

sub getSidecarFiles {
    my ($class, $file, $callback) = @_;
    $callback //= sub {};
    my @sidecar;
    my ($dir, $name, $nameStart) = $file =~ /(.+)\\((.+)\.\w+)$/;
    my $nameStartRe = qr/^\Q$nameStart\E/i;

    my $names = RJK::Files->getEntries($dir) // [];
    foreach (@$names) {
        next unless /$nameStartRe/ and $_ ne $name;
        push @sidecar, $_;
        $callback->($_, $dir, $name, $nameStart);
    }
    return \@sidecar, $dir, $name, $nameStart;
}

1;
