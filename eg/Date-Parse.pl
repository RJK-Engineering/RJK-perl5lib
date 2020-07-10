use strict;
use warnings;

use Date::Parse;
print str2time('1/2/2016 11:50AM'), "\n";
print str2time('2-1-2016 11:50:00'), "\n";

my $s = '2012.3.4 5:6.7';
my @t = split /[:\. ]/, $s;
die if @t != 6;
my $t = sprintf "%u:%02u:%02uT%02u:%02u:%02u", @t;

print "$t\n";
print str2time($t), "\n";

$t = "03/04/2012 05:06:07";
print "$t\n";
print str2time($t), "\n";

$, = " ";
print localtime(str2time($t)), "\n";
