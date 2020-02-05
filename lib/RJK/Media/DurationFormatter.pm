package RJK::Media::DurationFormatter;

use strict;
use warnings;

use RJK::Media::IDuration;

sub new {
    my $self = bless {}, shift;
    $self->{format} = shift || "%02h:%02m:%06.3s";
    return $self;
}

sub format {
    my ($self, $dur, $precision) = @_;
    $dur = $dur->duration if UNIVERSAL::isa($dur, "RJK::Media::IDuration");

    my $hours = int $dur / 3600;
    $dur -= $hours * 3600;
    my $mins = int $dur / 60;
    $dur -= $mins * 60;

    my $str = $self->{format};
    $str =~ s/(%\d*)h/sprintf "$1u", $hours/ge;
    $str =~ s/(%\d*)m/sprintf "$1u", $mins/ge;
    $str =~ s/%(\d+\.\d+|)s/sprintf "%$1f", $dur/ge;
    return $str;
}

1;
