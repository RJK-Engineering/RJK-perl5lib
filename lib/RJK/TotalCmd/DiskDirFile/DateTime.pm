package RJK::TotalCmd::DiskDirFile::DateTime;

use strict;
use warnings;

use Time::Local 'timelocal';

sub parse {
    my $self = shift;
    my @t = reverse split /[:\. ]/, shift;
    die if @t != 6;
    $t[5] -= 1900;
    $t[4]--;
    return timelocal(@t);
}

sub format {
    my $self = shift;
    my @t = localtime shift;
    return (sprintf("%s.%s.%s", $t[5]+1900, $t[4]+1, $t[3]),
            sprintf("%s:%s.%s", $t[2], $t[1], $t[0]));
}

1;
