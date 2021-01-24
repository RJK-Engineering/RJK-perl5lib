package RJK::File::Sidecar;

use strict;
use warnings;

use RJK::Files;

sub getSidecarFiles {
    my ($class, $file, $callback) = @_;
    $callback //= sub {};
    my @sidecar;
    my ($dir, $filename, $basename) = $file =~ /(.+)\\((.+)\.\w+)$/;
    my $basenameRegex = qr/^\Q$basename\E/i;

    foreach (@{RJK::Files->getEntries($dir)}) {
        next unless /$basenameRegex/ and $_ ne $filename;
        push @sidecar, $_;
        $callback->($_, $dir, $filename, $basename);
    }
    return \@sidecar, $dir, $filename, $basename;
}

1;
