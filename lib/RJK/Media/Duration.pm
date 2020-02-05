package RJK::Media::Duration;
use parent "RJK::Media::IDuration";

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    $self->{seconds} = parseDuration(shift);
    return $self;
}

sub duration {
    $_[0]{seconds};
}

sub time {
    formatTime($_[0]{seconds});
}

##############################################################################
=begin

Time duration syntax
http://ffmpeg.org/ffmpeg-utils.html#time-duration-syntax
   * [-][HH:]MM:SS[.m...]
      * Two letters means max two digits
      * m... = decimal part
   * [-]S+[.m...]

=cut
##############################################################################

sub parseDuration {
    my $dur = shift;
    my $seconds;

    if ($dur =~ /^(-)?(?:(\d\d?):)?(\d\d?):(\d\d?(\.\d+)?)$/) {
        $seconds = ($2||0) * 3600 + $3 * 60 + $4;
        $seconds *= -1 if $1;
    } elsif ($dur =~ /^(-?\d+(?:\.\d+)?)$/) {
        $seconds = $1;
    } else {
        die "Invalid format";
    }
    return $seconds;
}

sub formatTime {
    my $s = shift;

    my $hours = int $s / 3600;
    $s -= $hours * 3600;
    my $mins = int $s / 60;
    $s -= $mins * 60;

    return sprintf("%u:%02u:%5.3f", $hours, $mins, $s)
}

1;
