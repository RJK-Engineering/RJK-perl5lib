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

    my $names = RJK::Files->getEntries($dir) // [];
    foreach my $name (@$names) {
        next unless /$basenameRegex/ and $name ne $filename;
        push @sidecar, $name;
        $callback->($name, $dir, $filename, $basename);
    }
    return \@sidecar, $dir, $filename, $basename;
}

1;
