use strict;
use warnings;

#~ c:\workspace\RJK-perl5lib\lib\RJK\Media\Timecode.pm
#~ c:\workspace\RJK-perl5lib\lib\RJK\Media\Timecode~.pm
#~ c:\workspace\RJK-perl5lib\lib\RJK\Media\TimeFormat.pm
#~ c:\workspace\RJK-perl5lib\lib\RJK\Duration~.pm
#~ c:\workspace\RJK-perl5lib\lib\RJK\Media\Duration.pm
#~ c:\workspace\RJK-perl5lib\lib\RJK\Media\DurationFormatter.pm
#~ c:\workspace\RJK-perl5lib\lib\RJK\Media\IDuration.pm

use RJK::Time;
use RJK::TimeFormatter;
use RJK::TimeParser;

my $t1 = RJK::TimeParser->parse("30:00:00");
my $t2 = RJK::TimeParser->parse("12:34:56.123456");
my $t3 = RJK::TimeParser->parse("1:23:45.6789");
my $t4 = RJK::TimeParser->parse("1:23");
my $t5 = RJK::TimeParser->parse(123.456789);

printf "%s\n", RJK::TimeFormatter->format($t1);
printf "%s\n", RJK::TimeFormatter->format($t2);
printf "%s\n", RJK::TimeFormatter->format($t3);
printf "%s\n", RJK::TimeFormatter->format($t4);
printf "%s\n", RJK::TimeFormatter->format($t5);

my $t = $t1->minus($t2)->minus($t3)->minus($t4)->minus($t5);
print "15:57:51.740855\n";
my $precision = 6;
printf "%s\n", RJK::TimeFormatter->format($t, $precision);

$t1 = RJK::TimeParser->parse("-30:00:00");
$t2 = RJK::TimeParser->parse("-12:34:56.123456");
$t3 = RJK::TimeParser->parse("-1:23:45.6789");
$t4 = RJK::TimeParser->parse("-1:23");
$t5 = RJK::TimeParser->parse(-123.456789);

printf "%s\n", RJK::TimeFormatter->format($t1);
printf "%s\n", RJK::TimeFormatter->format($t2);
printf "%s\n", RJK::TimeFormatter->format($t3);
printf "%s\n", RJK::TimeFormatter->format($t4);
printf "%s\n", RJK::TimeFormatter->format($t5);

$t = $t1->minus($t2)->minus($t3)->minus($t4)->minus($t5);
print "-15:57:51.740855\n";
printf "%s\n", RJK::TimeFormatter->format($t, $precision);
