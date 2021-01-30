package RJK::Filename;

use strict;
use warnings;

use RJK::Sites;

sub cleanup {
    my ($class, $filename) = @_;
    $filename =~ s/\.\w+$//;
    foreach (keys %{RJK::Sites->all}) {
        $filename =~ s/-$_-.+//i;
    }
    my @words = $filename =~ /(\w+)/g;
    return wantarray ? @words : join " ", @words;
}

1;
