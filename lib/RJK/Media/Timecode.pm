package RJK::Media::Timecode;
use parent "RJK::Media::IDuration";

use strict;
use warnings;

sub new {
    my $self = bless {}, shift;
    my $tc = shift;
    $self->{fps} = shift;
    $self->{seconds} = parseTimecode($tc, $self->{fps});
    return $self;
}

sub fps {
    $_[0]{fps};
}

sub duration {
    $_[0]{seconds};
}

sub frames {
    int $_[0]{seconds} * $_[0]{fps};
}

sub timecode {
    formatTimecode($_[0]{seconds}, $_[0]{fps});
}

##############################################################################
=begin

Timecode syntax
   * [HH:]MM:SS:FF
      * Two letters means max two digits
      * FF = frames

=cut
##############################################################################

sub parseTimecode {
    my ($tc, $fps) = @_;
    my $seconds;

    if ($tc =~ /^(-)?(?:(\d\d?):)?(\d\d?):(\d\d?):(\d\d?)$/) {
        $seconds = ($2||0) * 3600 + $3 * 60 + $4 + $5/$fps;
        $seconds *= -1 if $1;
    } else {
        die "Invalid format";
    }
    return $seconds;
}

sub formatTimecode {
    my ($seconds, $fps) = @_;

    my $hours = int $seconds / 3600;
    $seconds -= $hours * 3600;
    my $mins = int $seconds / 60;
    $seconds -= $mins * 60;

    return sprintf "%u:%02u:%02u:%02u", $hours, $mins, $seconds,
        ($seconds - int($seconds) + .5/$fps) * $fps;
}

1;
