use strict;
use warnings;

use RJK::Media::Duration;
use RJK::Media::DurationFormatter;
use RJK::Media::Timecode;

my $d = new RJK::Media::Duration("12:34:56.789");
my $tc = new RJK::Media::Timecode("12:34:56:24", 25);

printf "duration\t%s\n", $d->duration;
printf "time\t%s\n", $d->time;

printf "duration\t%s\n", $tc->duration;
printf "timecode\t%s\n", $tc->timecode;
printf "frames\t%s\n", $tc->frames;
printf "fps\t%s\n", $tc->fps;

$d = new RJK::Media::Duration($tc->duration);

printf "duration\t%s\n", $d->duration;
printf "time\t%s\n", $d->time;

print RJK::Media::DurationFormatter->new->format($d);
