package RJK::TimeParser;

use strict;
use warnings;

# https://ffmpeg.org/ffmpeg-utils.html#time-duration-syntax
# [-][[H]H:][M]M:[S]S[.m...]
# [-]S+[.m...][s|ms|us]
# TODO [s|ms|us]
sub parse {
    my ($class, $string) = @_;
    $string // die "Undefined value";

    my (@t, $s);
    if (@t = $string =~ /^ (-?) (?:(\d?\d):)? (\d?\d):(\d?\d) (?:\.(\d+))? $/x) {
        $s = ($t[1]||0)*3600 + $t[2]*60 + $t[3];
        $s = 0 + ("$t[0]$s." . ($t[4]||0));
    } elsif (@t = $string =~ /^ (-?) (\d+) (?:\.(\d+))? $/x) {
        $s = 0 + ("$t[0]$t[1]." . ($t[2]||0));
    } else {
        die "Invalid time format: $string";
    }
    return bless { seconds => $s }, 'RJK::Time';
}

1;
